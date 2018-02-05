fun is_older (date1 : int*int*int, date2 : int*int*int) =
    if (#1 date1) > (#1 date2)
    then false		
    else if (#1 date1) = (#1 date2) andalso (#2 date1) > (#2 date2)
    then false
    else if (#1 date1) = (#1 date2) andalso (#2 date1) = (#2 date2) andalso (#3 date1) > (#3 date2)
    then false
    else true	    

fun number_in_month (date: (int*int*int) list, month: int) =
	if null date
	then 0
	else
	    let val tl_num = number_in_month((tl date), month)
	    in if (#2 (hd date)) = month
	       then tl_num + 1
	       else tl_num
	    end	
				    
fun number_in_months (date: (int*int*int) list, month: int list) =
    if null month
    then 0
    else let val num_hd = number_in_month(date, (hd  month))
	 in num_hd + number_in_months(date, (tl  month))
	 end
	     
fun dates_in_month (date: (int*int*int) list, month: int) =
    if null date
    then []
    else
	let val date_list = dates_in_month((tl date), month)
	in if (#2 (hd date)) = month
	   then (hd date) ::  date_list
	   else date_list
	end	

fun dates_in_months (date: (int*int*int) list, month: int list) =
    if null month
    then []
    else
	let val list_hd = dates_in_month(date, (hd month))
	in list_hd @ dates_in_months(date, (tl month))
	end
	    
fun get_nth (input: string list, n: int) =
    if (null input) orelse n < 0
    then ""
    else if n = 1
    then (hd input)
    else get_nth((tl input), n-1)


fun date_to_string (date: int*int*int) =
    let val month_name = ["January","February","March","April","May","June","July","August","September","October","November","December"]
    in get_nth(month_name, (#2 date)) ^ " " ^ (Int.toString (#3 date)) ^ ", " ^  (Int.toString (#1 date))
    end

fun number_before_reaching_sum (sum: int, input: int list) =
    let fun initial (sum, input: int list, pos: int) =
	    if (sum <= (hd input))
	    then pos - 1
	    else initial (sum - (hd input), tl input, pos + 1 ) 
    in
	initial (sum, input, 1)
    end

	
fun what_month (day: int) =
    let val day_of_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    in
	number_before_reaching_sum (day, day_of_month) + 1
    end

fun month_range (day1: int, day2: int) =
    if day2 < day1
    then []
    else if day1 = day2
    then [what_month (day1)]
    else what_month(day1) :: month_range (day1+1, day2)

					 
fun oldest (day_lists: (int*int*int) list) =
    if null day_lists
    then NONE
    else
	let val oldest_date = oldest (tl day_lists)
	in if isSome oldest_date  andalso is_older ((valOf oldest_date), (hd day_lists))
	    then oldest_date
	    else SOME (hd day_lists)
	end

	   
