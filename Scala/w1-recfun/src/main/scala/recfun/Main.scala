package recfun

object Main {
  def main(args: Array[String]) {
    println("Pascal's Triangle")
    for (row <- 0 to 10) {
      for (col <- 0 to row)
        print(pascal(col, row) + " ")
      println()
    }
  }

  /**
    * Exercise 1
    */
  def pascal(c: Int, r: Int): Int = {
    if (c == 0 || r == c)
      1
    else
      pascal(c - 1, r - 1) + pascal(c, r - 1)
  }


  /**
    * Exercise 2
    */
  def balance(chars: List[Char]): Boolean = {

    def balanceHelper(chars: List[Char], cur: Int): Boolean = {
      if (cur < 0) false
      else if (cur == 0 && chars.isEmpty)
        true
      else
        balanceHelper(chars.tail, cur + isParenthesis(chars.head))
    }

    def isParenthesis(char: Char): Int = {
      if (char == '(')
        1
      else if (char == ')')
        -1
      else
        0
    }

    balanceHelper(chars, 0)


  }

  /**
    * Exercise 3
    */
  def countChange(money: Int, coins: List[Int]): Int = {

      if (coins.isEmpty && money == 0) 1
      else if (coins.isEmpty) 0
      else if (coins.head > money) countChange(money, coins.tail)
      else countChange(money - coins.head, coins) + countChange(money, coins.tail)

      }

}