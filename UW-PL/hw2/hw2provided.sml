(* Dan Grossman, Coursera PL, HW2 Provided Code *)

(* if you use this function to compare two strings (returns true if the same
   string), then you avoid several of the functions in problem 1 having
   polymorphic types that may be confusing *)
fun same_string(s1 : string, s2 : string) =
    s1 = s2

(* put your solutions for problem 1 here *)

fun all_except_option (First: string, Second: string list) =
    case Second of
	[] => NONE
      | x::xs =>
	if same_string (x, First)
	then  SOME xs
	else
	    case all_except_option (First, xs) of
		NONE => NONE
	      | SOME y =>  SOME (x::y) 
	
		   
fun get_substitutions1 (sll: string list list, s: string) =
    case sll of
	[] => []
      | x::xs =>
	case all_except_option (s,x) of
	    NONE => get_substitutions1 (xs, s)
	  | SOME y => y @ get_substitutions1 (xs, s)

fun get_substitutions2 (sll: string list list, s: string) =
    let fun aux (sll, s, acc: string list) =
	    case sll of
		[] => acc
	      | x::xs =>
		case all_except_option (s,x) of
		    NONE => aux (xs, s, acc)
		  | SOME y => aux (xs, s, acc@y) (* NOT y@acc HERE! *)
    in
	aux (sll,s,[])
    end


fun similar_names (sll: string list list, full_name: {first:string, middle:string, last:string}) =
    let val {first = first, middle = middle, last = last} = full_name
	fun aux (first_sll, acc) =
	    case first_sll of
		[] => acc
	      | x::xs => {first = x, last = last, middle = middle} :: aux(xs,acc) 
    in case get_substitutions2 (sll, first) of
	   [] => full_name :: aux ([], [])
	 | x::xs => full_name :: aux (x::xs, []) 
    end
	
(* you may assume that Num is always used with values 2, 3, ..., 10
   though it will not really come up *)
datatype suit = Clubs | Diamonds | Hearts | Spades
datatype rank = Jack | Queen | King | Ace | Num of int 
type card = suit * rank

datatype color = Red | Black
datatype move = Discard of card | Draw 

exception IllegalMove
				 
			  
(* put your solutions for problem 2 here *)

	      
fun card_color card =
    case card of
	(Clubs, _) => Black
      | (Spades, _) => Black
      | (Diamonds, _) => Red
      | (Hearts, _) => Red

fun card_value card =
    case card of
	(_, (Num i)) => i
      | (_, Ace) => 11
      | (_, _) => 10 



fun remove_card (cl: card list, c: card, e: exn) =
    case cl of
	[] => raise e
      | x::xs =>
	if (x = c)
	then xs
	else x:: remove_card (xs, c, e)
		
fun all_same_color (cl: card list) =
    case cl of
	[] => true
      | _::[] => true
      | x::(y::xs) => ((card_color x) =  (card_color y)) andalso all_same_color (y::xs)

fun sum_cards (cl: card list) =
    let fun sum (cl, acc) =
	    case cl of
		[] => acc
	      | x::xs => sum (xs, acc + card_value(x)) 
    in
	sum (cl, 0)
    end

fun score (cl: card list, goal: int) =
    let val sum = sum_cards (cl)
    in
	case all_same_color (cl) of
	    true => (case (sum > goal) of
			 true => 3 * (sum - goal) div 2
		       | false => (goal - sum) div 2)
          | false => (case (sum > goal) of
			 true => 3 * (sum - goal) 
		       | false => (goal - sum))
    end

fun officiate (cl: card list, ml:move list, goal:int) =
    let
	fun play (state) =
	    case state of 
		([], _, goal, held) => score (held, goal)
	      | (_, [], goal, held) => score (held, goal)
	      | (c::cs, m::ms, goal, held) =>
		case m of
		    Draw => (case ms of
				 [] => score (held @[c], goal)
			       | _ =>  if (sum_cards (held) + card_value (c) > goal)
				       then score (held @ [c], goal)
				       else play (cs, ms, goal, held @ [c]))
		  | (Discard c) => play (cs, ms, goal, remove_card(held, c, IllegalMove))		
    in
	play (cl, ml, goal, [])
    end
	      
(*
fun officiate (cards,plays,goal) =
    let 
        fun loop (current_cards,cards_left,plays_left) =
            case plays_left of
                [] => score(current_cards,goal)
              | (Discard c)::tail => 
                loop (remove_card(current_cards,c,IllegalMove),cards_left,tail)
              | Draw::tail =>
                (* note: must score immediately if go over goal! *)
                case cards_left of
                    [] => score(current_cards,goal)
                  | c::rest => if sum_cards (c::current_cards) > goal
                               then score(c::current_cards,goal)
                               else loop (c::current_cards,rest,tail)
    in 
        loop ([],cards,plays)
    end
*)
