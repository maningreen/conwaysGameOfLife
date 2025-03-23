import Control.Concurrent
import System.Random
import System.Random.Stateful
import UI.HSCurses.Curses
import Data.Binary (Word32)
import Foreign (toBool)

main :: IO ()
main = do {
            initCurses;
            initScr;
            echo False;
            noDelay stdScr True;
            cursSet CursorInvisible;
            gen <- getStdGen;
            grid <- initGrid gen;
            gameLoop Running grid;
            endWin;
          }

data State = Running deriving (Enum, Eq)

gameLoop :: State -> Grid -> IO ()
gameLoop state grid = let 
    sleepTime = 20000
  in if state == Running then do {
    printGrid grid;
    refresh;
    threadDelay sleepTime;
    c <- getch;
    if c == 113 then
      return ()
    else
      gameLoop Running (updateGrid grid);
  } else 
    return ()

manageSelection :: ButtonEvent -> Grid -> Grid
manageSelection ev x = let  
    mouseEv = MouseEvent 0 0 0 0 [ButtonClicked 0]
    xPos :: Int
    xPos = mouseEventX mouseEv
    yPos :: Int
    yPos = mouseEventY mouseEv
    checkSame :: ((Int, Int), Int) -> Int
    checkSame ((x, y), v) = if x == xPos && y == yPos then
        1
      else
        0
  in do {
    map (map checkSame) (zipGrid x);
  }; 

type Grid = [[Int]]
updateGrid :: Grid -> Grid
updateGrid g = map (map (processCell g)) (zipGrid g)

zipGrid :: Grid -> [[((Int, Int), Int)]]
zipGrid g = let 
    -- this function takes in an (Int, [(Int, Bool)]) and should return an [((Int, Int), Bool)]
    embedY :: Grid -> [[(Int, Int)]]
    embedY = map (zip [0..])
    embedX :: [[(Int, Int)]] -> [(Int, [(Int, Int)])]
    embedX  = zip [0..]
    fixFormatting :: [(Int, [(Int, Int)])] -> [[((Int, Int), Int)]]
    fixFormatting list = let 
        fixOne :: (Int, [(Int, Int)]) -> [((Int, Int), Int)]
        fixOne (a, b) = map (\ x -> ((a, fst x), snd x)) b
      in map fixOne list
    in fixFormatting (embedX (embedY g))

printGrid :: Grid -> IO ()
printGrid x = let 
    zipped = zipGrid x
    fixFormat :: [[IO ()]] -> IO ()
    fixFormat x = sequence_ (concat x)
  in fixFormat (map (map printItem) zipped)
    where printItem ((x, y), b) = mvAddCh x y (cellToChar b)

getNeighbourCount :: ((Int, Int), Int) -> Grid -> Int
getNeighbourCount item grid = let
    getItem :: (Int, Int) -> Int
    getItem p = grid !! fst p !! snd p

    offset :: (Int, Int) -> (Int, Int) -> (Int, Int)
    offset (xP, yP) (xO, yO) = (xO + xP, yO + yP)

    toInt :: Bool -> Int
    toInt True = 1
    toInt False = 0

    getOffsetValue :: (Int, Int) -> Bool
    getOffsetValue off = let 
        offsetedVal = offset (fst item) off
      in if (not (outaBounds offsetedVal)) then toBool (getItem offsetedVal) else False
        where outaBounds (x, y) = x < 0 || y < 0 || x >= (length grid) - 1 || y >= length (head grid)
  in
      -- here we do a lot.
      toInt (getOffsetValue (-1, -1)) + toInt (getOffsetValue (-1, 0)) + toInt (getOffsetValue (-1, 1)) +
      toInt (getOffsetValue (0, -1)) + toInt (getOffsetValue (0, 1)) +
      toInt (getOffsetValue (1, -1)) + toInt (getOffsetValue (1, 0)) + toInt (getOffsetValue (1, 1))

processCell :: Grid -> ((Int, Int), Int) -> Int
processCell grid cell = let 
    neighbourCount = getNeighbourCount cell grid
    getItem p = grid !! fst p !! snd p
    alive = getItem (fst cell)
    toInt :: Bool -> Int
    toInt True = 1
    toInt False = 0
  in if alive == 1 then 
      toInt (neighbourCount == 2 || neighbourCount == 3)
    else
      toInt (neighbourCount == 3)


cellToChar :: Int -> Word32
cellToChar 1 = 42
cellToChar 0 = 32
cellToChar _ = 42

initGrid :: StdGen -> IO Grid
initGrid gen = let 
    buildArr :: Int -> StdGen -> ([Int], StdGen)
    buildArr targSize g
      | targSize > 0  = let 
          nextArr = buildArr (targSize - 1) (snd randVal)
        in (fst randVal `mod` 2 : fst nextArr, snd nextArr)
      | targSize == 0 = ([], snd randVal)
      where randVal = random g :: (Int, StdGen);
    buildGrid :: (Int, Int) -> StdGen -> Grid
    buildGrid (sizeX, sizeY) g
      | sizeY > 0 = let 
              arr = buildArr sizeX g ;
              nextCall = buildGrid (sizeX, sizeY - 1) (snd arr);
            in fst arr :  nextCall
      | sizeY == 0 = [[]]
  in do {
        (y, x) <- scrSize;
        let baseMap = buildGrid (x, y) gen in
        return baseMap;
      }
