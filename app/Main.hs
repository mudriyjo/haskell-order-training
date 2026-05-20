{-# LANGUAGE InstanceSigs #-}
{-# LANGUAGE BangPatterns #-}

module Main where

import Data.Char (toUpper)
import Text.Read (readMaybe)
import Control.Monad (foldM)

-- ============================================================================
-- Упражнения для рефреша Haskell: основы, ADT, типаклассы, Functor → Monad.
--
-- ПРАВИЛА:
--   1. Не пользуйся встроенными length, reverse, map, filter, fmap там,
--      где их просят реализовать руками.
--   2. Везде где `undefined` — это место для твоей реализации.
--   3. Проверь в REPL примеры из комментариев (-- >>>), или раскомментируй
--      main внизу и запусти `runhaskell HaskellExercises.hs` для авто-проверок.
--
-- ПОРЯДОК ПРОХОЖДЕНИЯ: сверху вниз. Поздние задачи иногда зависят от ранних
-- (например, Foldable Tree требует Functor Tree уже определённым).
-- ============================================================================


-- ╔════════════════════════════════════════════════════════════════════════╗
-- ║ Часть 1: Рекурсия, паттерн-матчинг, базовые операции                  ║
-- ╚════════════════════════════════════════════════════════════════════════╝

-- 1.1. Длина списка через рекурсию.
-- >>> myLength [1,2,3,4]    -- 4
-- >>> myLength ""           -- 0
myLength :: [a] -> Int
myLength xs = myLengthHelper xs 0
    where myLengthHelper [] !acc = acc
          myLengthHelper (_ : xz) !acc = myLengthHelper xz (acc + 1)

-- 1.2. Реверс списка.
-- >>> myReverse [1,2,3]     -- [3,2,1]
-- >>> myReverse "hello"     -- "olleh"
myReverse :: [a] -> [a]
myReverse = undefined

-- 1.3. Свой map.
-- >>> myMap (*2) [1,2,3]    -- [2,4,6]
-- >>> myMap toUpper "abc"   -- "ABC"
myMap :: (a -> b) -> [a] -> [b]
myMap = undefined

-- 1.4. Свой filter.
-- >>> myFilter even [1..10] -- [2,4,6,8,10]
myFilter :: (a -> Bool) -> [a] -> [a]
myFilter = undefined

-- 1.5. Свой foldr. Заметь сигнатуру — это фундаментальная операция.
-- >>> myFoldr (+) 0 [1,2,3,4]    -- 10
-- >>> myFoldr (:) [] [1,2,3]     -- [1,2,3]  -- foldr (:) [] == id для списков
myFoldr :: (a -> b -> b) -> b -> [a] -> b
myFoldr = undefined

-- 1.6. Безопасное деление: Nothing при делении на 0.
-- >>> safeDivide 10 2        -- Just 5
-- >>> safeDivide 10 0        -- Nothing
safeDivide :: Int -> Int -> Maybe Int
safeDivide = undefined

-- 1.7. Безопасный head.
-- >>> safeHead [1,2,3]              -- Just 1
-- >>> safeHead ([] :: [Int])        -- Nothing
safeHead :: [a] -> Maybe a
safeHead = undefined

-- 1.8. Поиск в ассоциативном списке (как стандартный lookup).
-- >>> myLookup "b" [("a",1),("b",2),("c",3)]   -- Just 2
-- >>> myLookup "z" [("a",1)]                   -- Nothing
myLookup :: Eq k => k -> [(k, v)] -> Maybe v
myLookup = undefined

-- 1.9. Удалить ПОДРЯД идущие дубликаты (не все дубликаты!).
-- >>> compress "aaaabccaadeeee"     -- "abcade"
-- >>> compress [1,1,2,2,2,3,1,1]    -- [1,2,3,1]
compress :: Eq a => [a] -> [a]
compress = undefined

-- 1.10. Run-length encoding: список (количество, элемент).
-- >>> runLength "aaabbc"            -- [(3,'a'),(2,'b'),(1,'c')]
-- >>> runLength ""                  -- []
runLength :: Eq a => [a] -> [(Int, a)]
runLength = undefined


-- ╔════════════════════════════════════════════════════════════════════════╗
-- ║ Часть 2: Алгебраические типы данных                                    ║
-- ╚════════════════════════════════════════════════════════════════════════╝

data Tree a = Leaf | Node a (Tree a) (Tree a)
  deriving (Show, Eq)

-- 2.1. Вставка в бинарное дерево поиска (BST).
-- Дубликаты — игнорируй (или клади в любую сторону, как удобно).
-- >>> insertBST 5 (insertBST 3 (insertBST 7 Leaf))
insertBST :: Ord a => a -> Tree a -> Tree a
insertBST = undefined

-- 2.2. Обход in-order. Из BST даёт отсортированный список.
-- >>> toListInOrder (insertBST 2 (insertBST 1 (insertBST 3 Leaf)))   -- [1,2,3]
toListInOrder :: Tree a -> [a]
toListInOrder = undefined

-- 2.3. Глубина дерева. Leaf имеет глубину 0.
-- >>> treeDepth Leaf                              -- 0
-- >>> treeDepth (Node 1 Leaf (Node 2 Leaf Leaf))  -- 2
treeDepth :: Tree a -> Int
treeDepth = undefined

-- 2.4. Геометрические фигуры. Треугольник — формула Герона.
data Shape = Circle Double | Rectangle Double Double | Triangle Double Double Double
  deriving Show

-- >>> area (Circle 1)              -- ~3.14159
-- >>> area (Rectangle 3 4)         -- 12.0
-- >>> area (Triangle 3 4 5)        -- 6.0
area :: Shape -> Double
area = undefined


-- ╔════════════════════════════════════════════════════════════════════════╗
-- ║ Часть 3: Functor                                                       ║
-- ╠════════════════════════════════════════════════════════════════════════╣
-- ║ Functor — структура, по содержимому которой можно применить функцию,   ║
-- ║ сохраняя саму структуру.                                               ║
-- ║   fmap :: (a -> b) -> f a -> f b                                       ║
-- ║                                                                        ║
-- ║ Законы:                                                                ║
-- ║   1. fmap id == id                                                     ║
-- ║   2. fmap (g . f) == fmap g . fmap f                                   ║
-- ╚════════════════════════════════════════════════════════════════════════╝

-- 3.1. Functor для своего Maybe.
data MyMaybe a = MyNothing | MyJust a
  deriving (Show, Eq)

instance Functor MyMaybe where
  fmap :: (a -> b) -> MyMaybe a -> MyMaybe b
  fmap = undefined
-- >>> fmap (+1) (MyJust 5)      -- MyJust 6
-- >>> fmap (+1) MyNothing       -- MyNothing

-- 3.2. Functor для своего Either.
-- Заметь: первый параметр (ошибка) НЕ меняется, fmap работает по второму.
data MyEither e a = MyLeft e | MyRight a
  deriving (Show, Eq)

instance Functor (MyEither e) where
  fmap :: (a -> b) -> MyEither e a -> MyEither e b
  fmap = undefined
-- >>> fmap (+1) (MyRight 5 :: MyEither String Int)       -- MyRight 6
-- >>> fmap (+1) (MyLeft "err" :: MyEither String Int)    -- MyLeft "err"

-- 3.3. Functor для Tree (из части 2).
instance Functor Tree where
  fmap :: (a -> b) -> Tree a -> Tree b
  fmap = undefined
-- >>> fmap (*2) (insertBST 1 (insertBST 2 (insertBST 3 Leaf)))

-- 3.4. Functor для пары одинаковых типов.
data Pair a = Pair a a
  deriving (Show, Eq)

instance Functor Pair where
  fmap :: (a -> b) -> Pair a -> Pair b
  fmap = undefined
-- >>> fmap (+10) (Pair 1 2)     -- Pair 11 12


-- ╔════════════════════════════════════════════════════════════════════════╗
-- ║ Часть 4: Applicative                                                   ║
-- ╠════════════════════════════════════════════════════════════════════════╣
-- ║ Applicative позволяет применять функции, обёрнутые в Functor.          ║
-- ║   pure  :: a -> f a                                                    ║
-- ║   (<*>) :: f (a -> b) -> f a -> f b                                    ║
-- ╚════════════════════════════════════════════════════════════════════════╝

-- 4.1. Applicative для MyMaybe.
instance Applicative MyMaybe where
  pure :: a -> MyMaybe a
  pure = undefined
  (<*>) :: MyMaybe (a -> b) -> MyMaybe a -> MyMaybe b
  (<*>) = undefined
-- >>> (+) <$> MyJust 1 <*> MyJust 2          -- MyJust 3
-- >>> (+) <$> MyJust 1 <*> MyNothing         -- MyNothing

-- 4.2. Applicative для MyEither — КОРОТКОЗАМЫКАЕТСЯ на первой ошибке.
instance Applicative (MyEither e) where
  pure = undefined
  (<*>) = undefined
-- >>> (+) <$> MyRight 1 <*> (MyRight 2 :: MyEither String Int)
--     -- MyRight 3
-- >>> (+) <$> (MyLeft "no" :: MyEither String Int) <*> MyLeft "also no"
--     -- MyLeft "no"   (первая ошибка побеждает)

-- 4.3. Свой список с Applicative — декартово произведение.
data MyList a = MyNil | MyCons a (MyList a)
  deriving (Show, Eq)

instance Functor MyList where
  fmap = undefined

instance Applicative MyList where
  pure = undefined
  (<*>) = undefined
-- >>> MyCons (+1) (MyCons (*2) MyNil) <*> MyCons 10 (MyCons 20 MyNil)
--     -- MyCons 11 (MyCons 21 (MyCons 20 (MyCons 40 MyNil)))

-- 4.4. Validation — Applicative, который НАКАПЛИВАЕТ ошибки.
-- Это КЛЮЧЕВОЕ упражнение: показывает, как разная алгебра одной формы
-- даёт разное поведение (Either ≠ Validation, хотя структурно похожи).
data Validation e a = Failure e | Success a
  deriving (Show, Eq)

instance Functor (Validation e) where
  fmap = undefined

-- Заметь требование Semigroup e — нужно чтобы СКЛАДЫВАТЬ ошибки через <>.
instance Semigroup e => Applicative (Validation e) where
  pure = undefined
  (<*>) = undefined
-- >>> Success (+) <*> Success 1 <*> Success 2
--     -- Success 3
-- >>> (Failure ["no email"] :: Validation [String] (Int -> Int -> Int))
--       <*> Failure ["bad password"] <*> Success 5
--     -- Failure ["no email","bad password"]   ← обе ошибки накопились


-- ╔════════════════════════════════════════════════════════════════════════╗
-- ║ Часть 5: Monad                                                         ║
-- ╠════════════════════════════════════════════════════════════════════════╣
-- ║ Monad добавляет к Applicative операцию:                                ║
-- ║   (>>=) :: m a -> (a -> m b) -> m b                                    ║
-- ║ Позволяет последующим шагам зависеть от результатов предыдущих.        ║
-- ║ NB: Validation НЕ может быть Monad — это упражнение на подумать.       ║
-- ╚════════════════════════════════════════════════════════════════════════╝

-- 5.1. Monad для MyMaybe.
instance Monad MyMaybe where
  (>>=) :: MyMaybe a -> (a -> MyMaybe b) -> MyMaybe b
  (>>=) = undefined

-- 5.2. Monad для MyEither.
instance Monad (MyEither e) where
  (>>=) = undefined

-- 5.3. Цепочка безопасных операций. Используй do-notation на стандартном Maybe.
-- Вычисляет ((x / a) * b) / c. Любое деление на 0 → Nothing для всей цепочки.
-- >>> safeChain 100 5 4 2     -- Just 40
-- >>> safeChain 100 0 4 2     -- Nothing
-- >>> safeChain 100 5 4 0     -- Nothing
safeChain :: Int -> Int -> Int -> Int -> Maybe Int
safeChain x a b c = undefined

-- 5.4. Банковский автомат с откатом.
-- Каждая операция: Deposit n (всегда успешно) или Withdraw n.
-- Если Withdraw превышает текущий баланс — вся последовательность даёт Nothing.
-- Используй foldM или do-notation.
data Op = Deposit Int | Withdraw Int deriving Show

-- >>> bankOps 100 [Deposit 50, Withdraw 30, Withdraw 100]    -- Just 20
-- >>> bankOps 100 [Deposit 50, Withdraw 30, Withdraw 200]    -- Nothing
-- >>> bankOps 100 []                                          -- Just 100
bankOps :: Int -> [Op] -> Maybe Int
bankOps = undefined


-- ╔════════════════════════════════════════════════════════════════════════╗
-- ║ Часть 6: Semigroup и Monoid                                            ║
-- ╠════════════════════════════════════════════════════════════════════════╣
-- ║ Semigroup: (<>) ассоциативно: (a <> b) <> c == a <> (b <> c)           ║
-- ║ Monoid:    + mempty, нейтральный элемент:                              ║
-- ║              mempty <> x == x == x <> mempty                           ║
-- ╚════════════════════════════════════════════════════════════════════════╝

-- 6.1. Sum — обёртка над Num с моноидом по сложению.
newtype MySum a = MySum { getMySum :: a }
  deriving (Show, Eq)

instance Num a => Semigroup (MySum a) where
  (<>) = undefined

instance Num a => Monoid (MySum a) where
  mempty = undefined
-- >>> getMySum (MySum 3 <> MySum 4 <> MySum 5)    -- 12
-- >>> getMySum (mempty :: MySum Int)              -- 0

-- 6.2. Product — моноид по умножению.
newtype MyProduct a = MyProduct { getMyProduct :: a }
  deriving (Show, Eq)

instance Num a => Semigroup (MyProduct a) where
  (<>) = undefined

instance Num a => Monoid (MyProduct a) where
  mempty = undefined
-- >>> getMyProduct (MyProduct 3 <> MyProduct 4)   -- 12
-- >>> getMyProduct (mempty :: MyProduct Int)      -- 1

-- 6.3. Max — полугруппа по максимуму. Подумай, почему НЕ Monoid без Bounded.
newtype MyMax a = MyMax { getMyMax :: a }
  deriving (Show, Eq)

instance Ord a => Semigroup (MyMax a) where
  (<>) = undefined
-- >>> getMyMax (MyMax 3 <> MyMax 7 <> MyMax 5)    -- 7


-- ╔════════════════════════════════════════════════════════════════════════╗
-- ║ Часть 7: Foldable и Traversable                                        ║
-- ╠════════════════════════════════════════════════════════════════════════╣
-- ║ Foldable:   свести структуру к одному значению.                        ║
-- ║ Traversable: пройти структуру, выполнив эффект для каждого элемента,   ║
-- ║              собрав результат обратно в структуру.                     ║
-- ╚════════════════════════════════════════════════════════════════════════╝

-- 7.1. Foldable для Tree. Минимум — реализовать foldr.
-- Остальные методы (sum, length, toList, и т.д.) получим бесплатно.
instance Foldable Tree where
  foldr :: (a -> b -> b) -> b -> Tree a -> b
  foldr = undefined
-- После реализации в REPL должно работать:
-- >>> sum (insertBST 1 (insertBST 2 (insertBST 3 Leaf)))         -- 6
-- >>> length (insertBST 1 (insertBST 2 Leaf))                    -- 2
-- >>> foldr (:) [] (insertBST 3 (insertBST 1 (insertBST 2 Leaf))) -- [1,2,3]

-- 7.2. Traversable для Tree.
-- Это упражнение мощно показывает связку Functor+Foldable+Applicative.
-- >>> traverse Just (insertBST 1 (insertBST 2 Leaf))    -- Just (...)
-- >>> traverse (\x -> if x > 0 then Just x else Nothing) (insertBST 1 Leaf)
instance Traversable Tree where
  traverse :: Applicative f => (a -> f b) -> Tree a -> f (Tree b)
  traverse = undefined

-- 7.3. Применение traverse: распарсить все строки или вернуть Nothing,
-- если хотя бы одна не распарсилась. Это ОДНА строчка через traverse.
-- >>> parseAll ["1", "2", "3"]        -- Just [1,2,3]
-- >>> parseAll ["1", "two", "3"]      -- Nothing
parseAll :: [String] -> Maybe [Int]
parseAll = undefined


-- ╔════════════════════════════════════════════════════════════════════════╗
-- ║ Часть 8: Применённые мини-задачи                                       ║
-- ╚════════════════════════════════════════════════════════════════════════╝

-- 8.1. Валидация формы с НАКОПЛЕНИЕМ всех ошибок.
-- Используй Validation [String] из части 4.
-- Правила:
--   - email: не пустой И содержит '@'
--   - age:   положительный (> 0)
--   - name:  не пустой
data UserForm = UserForm
  { formEmail :: String
  , formAge   :: Int
  , formName  :: String
  } deriving Show

data UserValid = UserValid
  { validEmail :: String
  , validAge   :: Int
  , validName  :: String
  } deriving Show

-- >>> validateUser (UserForm "a@b.c" 25 "Alex")
--     -- Success (UserValid {...})
-- >>> validateUser (UserForm "" (-1) "")
--     -- Failure ["email empty","age must be positive","name empty"]
-- >>> validateUser (UserForm "noatsign" 25 "Bob")
--     -- Failure ["email missing @"]
validateUser :: UserForm -> Validation [String] UserValid
validateUser = undefined

-- 8.2. Светофор: Red → Green → Yellow → Red → ...
data TrafficLight = Red | Yellow | Green deriving (Show, Eq)

-- >>> next Red     -- Green
-- >>> next Green   -- Yellow
-- >>> next Yellow  -- Red
next :: TrafficLight -> TrafficLight
next = undefined


-- ============================================================================
-- АВТО-ПРОВЕРКИ
-- После реализации задач раскомментируй последнюю строку и запусти:
--   runhaskell HaskellExercises.hs
-- ============================================================================

runChecks :: IO ()
runChecks = do
  putStrLn "=== Часть 1: основы ==="
  check "1.1 myLength [1..4]"         (myLength [1,2,3,4] == 4)
  check "1.1 myLength empty"          (myLength ("" :: String) == 0)
  check "1.2 myReverse"               (myReverse [1,2,3] == [3,2,1])
  check "1.3 myMap (*2)"              (myMap (*2) [1,2,3] == [2,4,6])
  check "1.4 myFilter even"           (myFilter even [1..10] == [2,4,6,8,10])
  check "1.5 myFoldr sum"             (myFoldr (+) 0 [1,2,3,4] == 10)
  check "1.6 safeDivide 10 2"         (safeDivide 10 2 == Just 5)
  check "1.6 safeDivide 10 0"         (safeDivide 10 0 == Nothing)
  check "1.7 safeHead [1,2]"          (safeHead [1,2,3] == Just 1)
  check "1.7 safeHead []"             (safeHead ([] :: [Int]) == Nothing)
  check "1.8 myLookup hit"            (myLookup "b" [("a",1),("b",2)] == Just 2)
  check "1.8 myLookup miss"           (myLookup "z" [("a",1::Int)] == Nothing)
  check "1.9 compress"                (compress "aaabbc" == "abc")
  check "1.10 runLength"              (runLength "aaabbc" == [(3,'a'),(2,'b'),(1,'c')])

  putStrLn "\n=== Часть 2: ADT ==="
  check "2.2 toListInOrder BST"
    (toListInOrder (insertBST 2 (insertBST 1 (insertBST 3 Leaf))) == [1,2,3])
  check "2.3 treeDepth Leaf"          (treeDepth (Leaf :: Tree Int) == 0)
  check "2.3 treeDepth nested"
    (treeDepth (Node 1 Leaf (Node 2 Leaf Leaf) :: Tree Int) == 2)
  check "2.4 area circle"             (abs (area (Circle 1) - pi) < 0.0001)
  check "2.4 area rectangle"          (area (Rectangle 3 4) == 12)
  check "2.4 area triangle"           (abs (area (Triangle 3 4 5) - 6) < 0.0001)

  putStrLn "\n=== Часть 3: Functor ==="
  check "3.1 fmap MyJust"             (fmap (+1) (MyJust 5) == MyJust 6)
  check "3.1 fmap MyNothing"          (fmap (+1) MyNothing == (MyNothing :: MyMaybe Int))
  check "3.2 fmap MyRight"
    (fmap (+1) (MyRight 5 :: MyEither String Int) == MyRight 6)
  check "3.2 fmap MyLeft"
    (fmap (+1) (MyLeft "err" :: MyEither String Int) == MyLeft "err")
  check "3.4 fmap Pair"               (fmap (+10) (Pair 1 2) == Pair 11 12)

  putStrLn "\n=== Часть 4: Applicative ==="
  check "4.1 (+) MyJust MyJust"       (((+) <$> MyJust 1 <*> MyJust 2) == MyJust 3)
  check "4.1 (+) MyJust MyNothing"
    (((+) <$> MyJust 1 <*> (MyNothing :: MyMaybe Int)) == MyNothing)
  check "4.2 MyEither short-circuit"
    (((+) <$> (MyLeft "no" :: MyEither String Int) <*> MyLeft "also no") == MyLeft "no")
  check "4.4 Validation success"
    (((+) <$> Success 1 <*> Success 2) == (Success 3 :: Validation [String] Int))
  check "4.4 Validation accumulates"
    (((+) <$> (Failure ["a"] :: Validation [String] Int) <*> Failure ["b"])
       == Failure ["a","b"])

  putStrLn "\n=== Часть 5: Monad ==="
  check "5.3 safeChain ok"            (safeChain 100 5 4 2 == Just 40)
  check "5.3 safeChain div-by-zero"   (safeChain 100 0 4 2 == Nothing)
  check "5.4 bankOps ok"
    (bankOps 100 [Deposit 50, Withdraw 30, Withdraw 100] == Just 20)
  check "5.4 bankOps overdraft"
    (bankOps 100 [Deposit 50, Withdraw 200] == Nothing)

  putStrLn "\n=== Часть 6: Semigroup/Monoid ==="
  check "6.1 MySum"                   (getMySum (MySum 3 <> MySum 4 <> MySum 5) == (12 :: Int))
  check "6.1 MySum mempty"            (getMySum (mempty :: MySum Int) == 0)
  check "6.2 MyProduct"               (getMyProduct (MyProduct 3 <> MyProduct 4) == (12 :: Int))
  check "6.2 MyProduct mempty"        (getMyProduct (mempty :: MyProduct Int) == 1)
  check "6.3 MyMax"                   (getMyMax (MyMax 3 <> MyMax 7 <> MyMax 5) == (7 :: Int))

  putStrLn "\n=== Часть 7: Foldable/Traversable ==="
  let t = insertBST 3 (insertBST 1 (insertBST 2 Leaf))
  check "7.1 sum Tree"                (sum t == 6)
  check "7.1 length Tree"             (length t == 3)
  check "7.3 parseAll ok"             (parseAll ["1","2","3"] == Just [1,2,3])
  check "7.3 parseAll fail"           (parseAll ["1","two","3"] == Nothing)

  putStrLn "\n=== Часть 8: Применённые ==="
  check "8.1 validateUser ok"         (isSuccess (validateUser (UserForm "a@b" 25 "Alex")))
  check "8.1 validateUser 3 errors"
    (case validateUser (UserForm "" (-1) "") of
       Failure errs -> length errs == 3
       _ -> False)
  check "8.2 next Red"                (next Red == Green)
  check "8.2 next Green"              (next Green == Yellow)
  check "8.2 next Yellow"             (next Yellow == Red)
  where
    check name passed =
      putStrLn $ (if passed then "  \x2713 " else "  \x2717 ") ++ name
    isSuccess (Success _) = True
    isSuccess _           = False

-- Раскомментируй для запуска через `runhaskell HaskellExercises.hs`:
main :: IO ()
main = runChecks

-- main :: IO ()
-- main = putStrLn "Реализуй задачи и раскомментируй runChecks в main."
