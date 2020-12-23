% PROJECT DETAILS:
% PROJECT NAME: SEAT PLANNING
%               HERE WE GIVE INPUTS AS 
%                             HOW MANY ROOMS WE HAVE, HOW MANY BENCHES IN EACH ROOM, 
%                             IN HOW MANY SHIFTS EXAMS WILL BE TAKEN,
%                             HOW MANY STUDENTS ARE THERE, HOW MANY TEACHERS ARE THERE.
%               HERE WE GET OUTPUT AS
%                             STATISTICS ABOUT STUDENTS,ROOMS,TEACHERS
%                             SEAT PLAN(HOW STUDENTS SHOULD BE ARRANGED IN AN EXAM HALL)
%
%HERE WE HAVE CONSIDERED ONLY ONE SHIFT AS IT TURNED OUT TO A BIT COMPLICATED TO IMPLEMENT WITH OUR PRIOR KNOWLEDGE IN MINIZINC.
%HERE WE HAVE CONSIDERED ONLY ONE YEAR OF STUDENTS FOR FOUR DEPARTMENTS.






                                    %        PARAMETERS ON ROOM      %
                                    %================================%


% HOW MANY ROOMS WE HAVE
int: rooms;

% IN HOW MANY SHIFTS EXAMS ARE TAKEN
int: shifts;

%HOW MANY AVAILABLE ROOMS WE HAVE
int: available_rooms;
available_rooms = rooms*shifts;

% NUMBER OF BENCHES IN EACH ROOM
int: benches_in_each_room;

% TOTAL NUMBER OF BENCHES
int: total_benches;
total_benches = available_rooms*benches_in_each_room;

%MAX STUDENT CAPACITY
int: max_seat;
max_seat = total_benches*2;

%TOTAL NUMBER OF BENCHES IN EACH ROW
int: benches_in_a_row;
benches_in_a_row = 3;

% TOTAL NUMBER OF ROWS
int: row_count;
row_count = total_benches div benches_in_a_row;




                               %        PARAMETERS ON STUDENTS     %
                               %===================================%

% NUMBER OF STUDENTS IN EACH ROW
int: column_count;
column_count = 6;

% NUMBER OF STUDENTS IN EACH COLUMN OF EACH ROOM
int: room_limit; 
room_limit = row_count div available_rooms;

% HOW MANY STUDENTS
int: students;

% HOW MANY BENCHES NEEDED
int: bench_needed;
bench_needed = (students div 2) + ( students mod 2);

%HOW MANY ROWS NEEDED
int: row_needed;
row_needed = (bench_needed div 3) + (true xor ((bench_needed mod 3) =0));

%HOW MANY ROWS IN EACH ROOM
int: row_in_each_room;
row_in_each_room = benches_in_each_room div 3;

%HOW MANY ROOMS USED
int: room_used;
room_used= (row_needed div row_in_each_room) + (true xor ((row_needed mod row_in_each_room) = 0));

%HOW MANY TEACHERS NEEDED
int: teachers;

%HOW MANY TEACHERS PER EACH ROOM
int: teachers_in_each_room;
teachers_in_each_room = (teachers div  room_used);

%HOW MANY EXTRA TEACHERS REMAINLING
int: remaining_teachers;
remaining_teachers = (teachers - (room_used*teachers_in_each_room));

%TOTAL NUMBER OF STUDENTS IN EACH ROOM
int: student_in_each_room;
student_in_each_room = row_in_each_room * 6;

%TOTAL NUMBER OF STUDENTS IN LAST ROOM
int: student_in_last_room;
student_in_last_room = (students - (room_used-1)*(row_in_each_room * 6));







                                    %         VARIABLES       %
                                    %=========================%

% variables used in iteration
int: i;
i = 0;
int: j;
j = 0;
   
%VARIABLES USED FOR SETTING THE LIMITS OF CONSTRAINTS FOR ROWS                                                          
set of int: Row = 1..row_needed;
set of int: Rupper = 1..row_needed-1;
set of int: Rlower = 2..row_needed;

%VARIABLES USED FOR SETTING THE LIMITS OF CONSTRAINTS FOR COLUMNS                                                          
set of int: Column = 1..column_count;
set of int: Cupper = 1..column_count-1;
set of int: Clower = 2..column_count;

%DEPARTMENT
enum dept = { CSE, EEE, MCE, CVL};
array[Row,Column] of var dept: seat_plan;

                                %       CONSTRAINTS ON INPUTS      %
                                %==================================%


% CHECK IF ROOM NUMBER HAS POSITIVE VALUE
constraint assert (
    rooms > 0,
  "\n\nNegative Room number detected.\n\n"
);


% CHECK IF SHIFT NUMBER HAS POSITIVE VALUE
constraint assert (
    shifts > 0,
  "\n\nNegative Shift number detected.\n\n"
);


% CHECK IF BENCH COUNT HAS POSITIVE VALUE
constraint assert (
    benches_in_each_room > 0,
  "\n\nNegative Bench count detected.\n\n"
);


% CHECK IF BENCH COUNT HAS VALID VALUE
constraint assert (
    (benches_in_each_room mod 3) = 0,
  "\n\nInvalid Bench count detected.\n Benches count should be multiple of 3\n"
);


% CHECK IF STUDENT COUNT HAS POSITIVE VALUE
constraint assert (
    students > 0,
  "\n\nNegative Student count detected.\n\n"
);


% CHECK IF STUDENT NUMBER IS GREATER THAN AVAILABLE SEATS
constraint assert (
    students < max_seat,
  "\n\nStudent number is greater than available seats.\n\n"
);

% CHECK IF TEACHER COUNT HAS POSITIVE VALUE
constraint assert (
    teachers > 0,
  "\n\nNegative Teacher count detected.\n\n"
);


% CHECK IF TEACHER NUMBER IS LESS THAN AVAILABLE ROOMS
constraint assert (
    room_used < teachers,
  "\n\nTeacher number is less than available rooms.\n\n"
);







                                    %       CONSTRAINTS       %
                                    %=========================%

%WE NEED TO MAKE SURE NO TWO STUDENTS OF THE SAME DEPARTMENT CAN SIT TOGETHER.
%SO BASICALLY THERE CAN NOT BE A STUDENT OF SAME DEPARTMENT IN THE FIRST CIRCLE OF HIM.


%THESE CONSTRAINTS MAKE SURE THAT ....
%... THE STUDENT BEHIND HIM IS NOT OF THE SAME DEPARTMENT.
constraint forall(i in Rupper, j in Column)  (seat_plan[i,j] != seat_plan[i+1,j]);

%... THE STUDENT IN FRONT OF HIM IS NOT OF THE SAME DEPARTMENT.
constraint forall(i in Rlower, j in Column)  (seat_plan[i,j] != seat_plan[i-1,j]);

%... THE STUDENT IN THE RIGHT SIDE OF HIM IS NOT OF THE SAME DEPARTMENT.
constraint forall(i in Row,    j in Cupper)  (seat_plan[i,j] != seat_plan[i,j+1]);

%... THE STUDENT IN THE LEFT SIDE OF HIM IS NOT OF THE SAME DEPARTMENT.
constraint forall(i in Row,    j in Clower)  (seat_plan[i,j] != seat_plan[i,j-1]);

%... THE STUDENT IN FRONT-LEFT COURNER OF HIM IS NOT OF THE SAME DEPARTMENT.
constraint forall(i in Rlower, j in Clower)(seat_plan[i,j] != seat_plan[i-1,j-1]);

%... THE STUDENT IN FRONT-RIGHT COURNER OF HIM IS NOT OF THE SAME DEPARTMENT.
constraint forall(i in Rlower, j in Cupper)(seat_plan[i,j] != seat_plan[i-1,j+1]);

%... THE STUDENT IN BEHIND-RIGHT COURNER OF HIM IS NOT OF THE SAME DEPARTMENT.
constraint forall(i in Rupper, j in Cupper)(seat_plan[i,j] != seat_plan[i+1,j+1]);

%... THE STUDENT IN BEHIND-LEFT COURNER OF HIM IS NOT OF THE SAME DEPARTMENT.
constraint forall(i in Rupper, j in Clower)(seat_plan[i,j] != seat_plan[i+1,j-1]);





                                    %          SOLVE          %
                                    %=========================%


solve satisfy;


                                    %          OUTPUT         %
                                    %=========================%



%output [show(t)];
output	
[	

  %STATISTICS GENERATION
  %FIRST ROOM PRINT
  
  if ((i = 1) /\ (j =1 ) /\ (((i div room_limit)+1) != room_used) )
        then 
        "\n\n\n" ++
		    "_________________________________________________________________________"++
        "\n" ++
		    "_________________________________________________________________________"++
        "\n" ++
		    "_________________________________________________________________________"++
        "\n\n" ++
        "                              SEAT ARRANGEMENT                           "++
        "\n" ++ 
        "                              ________________                           "++
        "\n\n\n" ++
        "Total number of available rooms : " ++
        show(available_rooms) ++ 
        "\n\n" ++
        "Total number of rooms needed    : " ++
        show(room_used) ++ 
        "\n\n" ++
        "Total number of available seats : " ++
        show(max_seat) ++ 
        "\n\n" ++
        "Total number of students        : " ++
        show(students) ++ 
        "\n\n" ++
        "Total number of teachers        : " ++
        show(teachers) ++ 
        "\n\n" ++
        "Number of teachers in each room : " ++
        show(teachers_in_each_room) ++ 
        "\n\n" ++
        "Number of extra teachers        : " ++
        show(remaining_teachers) ++ 
        "\n\n\n\n" ++
        ">>>Room no: 1" ++
        "\n" ++
        "_________________" ++
        "\n" ++
        "Number of students: " ++
        show(student_in_each_room) ++ 
        "\n\n" ++
        "\n" ++
		    "_________________________________________________________________________"++
        "\n\n" ++
        "|   "
        
        
        
          elseif ((i = 1) /\ (j =1 ) /\ (((i div room_limit)+1) = room_used) )
        then 
        "\n\n\n" ++
		    "_________________________________________________________________________"++
        "\n" ++
		    "_________________________________________________________________________"++
        "\n" ++
		    "_________________________________________________________________________"++
        "\n\n" ++
        "                              SEAT ARRANGEMENT                           "++
        "\n" ++ 
        "                              ________________                           "++
        "\n\n\n" ++
        "Total number of available rooms : " ++
        show(available_rooms) ++ 
        "\n\n" ++
        "Total number of rooms needed    : " ++
        show(room_used) ++ 
        "\n\n" ++
        "Total number of available seats : " ++
        show(max_seat) ++ 
        "\n\n" ++
        "Total number of students        : " ++
        show(students) ++ 
        "\n\n" ++
        "Total number of teachers        : " ++
        show(teachers) ++ 
        "\n\n" ++
        "Number of teachers in each room : " ++
        show(teachers_in_each_room) ++ 
        "\n\n" ++
        "Number of extra teachers        : " ++
        show(remaining_teachers) ++ 
        "\n\n\n\n" ++
        ">>>Room no: 1" ++
        "\n" ++
        "_________________" ++
        "\n" ++
        "Number of students: " ++
        show(student_in_last_room) ++ 
        "\n\n" ++
        "\n" ++
		    "_________________________________________________________________________"++
        "\n\n" ++
        "|   "
        
        
  elseif(j =1)
        then 
        "|   "
  else  "" 
  endif ++
  
  
  %SEAT PLAN PRINT
  
  if( ((i-1)*6+j) >students) /\ (i = row_needed)
  then
  "#######"
  else
  show(seat_plan[i,j]) 
  endif++
  
  %GENERATING ID
  
  %1ST CONDITION IF POSITION IS AN EVEN OR ODD POSITION IN A ROW WISE
  %2ND CONDITION TO FIND THE POSITION ACCORDING TO COLUMN WISE
  %3RD CONDITION TO CHECK IF THE ID IS LESS THAN 10 OR NOT
  if ( i mod 2 = 0 ) /\ (( j = 1 ) \/ ( j = 2 )) /\ (((((i div 2) -1)*3)+1)<10) /\ (((i-1)*6+j) <= students)
        then
        "-00"++
        show((((i div 2) -1)*3)+1)
  elseif ( i mod 2 = 0 ) /\ (( j = 3 ) \/ ( j = 4 )) /\ (((((i div 2) -1)*3)+2)<10) /\ (((i-1)*6+j) <= students)
        then
        "-00"++
        show((((i div 2) -1)*3)+2)
  elseif ( i mod 2 = 0 ) /\ (( j = 5 ) \/ ( j = 6 )) /\ (((((i div 2) -1)*3)+3)<10) /\ (((i-1)*6+j) <= students)
        then
        "-00"++
        show((((i div 2) -1)*3)+3)
  elseif ( i mod 2 != 0 ) /\ (( j = 1 ) \/ ( j = 2 )) /\ ((((((i+1) div 2) -1)*3)+1)<10) /\ (((i-1)*6+j) <= students)
        then
        "-00"++
        show(((((i+1) div 2) -1)*3)+1) 
  elseif ( i mod 2 != 0 ) /\ (( j = 3 ) \/ ( j = 4 )) /\ ((((((i+1) div 2) -1)*3)+2)<10) /\ (((i-1)*6+j) <= students)
        then
        "-00"++
        show(((((i+1) div 2) -1)*3)+2) 
  elseif ( i mod 2 != 0 ) /\ (( j = 5 ) \/ ( j = 6 )) /\ ((((((i+1) div 2) -1)*3)+3)<10) /\ (((i-1)*6+j) <= students)
        then
        "-00"++
        show(((((i+1) div 2) -1)*3)+3) 
        
        
  elseif ( i mod 2 = 0 ) /\ (( j = 1 ) \/ ( j = 2 )) /\ (((((i div 2) -1)*3)+1)>9) /\ (((((i div 2) -1)*3)+1)<100)  /\ (((i-1)*6+j) <= students)
        then
        "-0"++
        show((((i div 2) -1)*3)+1)
  elseif ( i mod 2 = 0 ) /\ (( j = 3 ) \/ ( j = 4 )) /\ (((((i div 2) -1)*3)+2)>9) /\ (((((i div 2) -1)*3)+2)<100)  /\ (((i-1)*6+j) <= students)
        then
        "-0"++
        show((((i div 2) -1)*3)+2)
  elseif ( i mod 2 = 0 ) /\ (( j = 5 ) \/ ( j = 6 )) /\ (((((i div 2) -1)*3)+3)>9) /\ (((((i div 2) -1)*3)+3)<100)  /\ (((i-1)*6+j) <= students)
        then
        "-0"++
        show((((i div 2) -1)*3)+3)
  elseif ( i mod 2 != 0 ) /\ (( j = 1 ) \/ ( j = 2 )) /\ ((((((i+1) div 2) -1)*3)+1)>9)/\ ((((((i+1) div 2) -1)*3)+1)<100)  /\ (((i-1)*6+j) <= students)
        then
        "-0"++
        show(((((i+1) div 2) -1)*3)+1) 
  elseif ( i mod 2 != 0 ) /\ (( j = 3 ) \/ ( j = 4 )) /\ ((((((i+1) div 2) -1)*3)+2)>9)/\ ((((((i+1) div 2) -1)*3)+2)<100) /\ (((i-1)*6+j) <= students)
        then
        "-0"++
        show(((((i+1) div 2) -1)*3)+2) 
  elseif ( i mod 2 != 0 ) /\ (( j = 5 ) \/ ( j = 6 )) /\ ((((((i+1) div 2) -1)*3)+3)>9)/\ ((((((i+1) div 2) -1)*3)+3)<100) /\ (((i-1)*6+j) <= students)
        then
        "-0"++
        show(((((i+1) div 2) -1)*3)+3) 
        
  
 elseif ( i mod 2 = 0 ) /\ (( j = 1 ) \/ ( j = 2 )) /\ (((((i div 2) -1)*3)+1)>99)  /\ (((i-1)*6+j) <= students)
        then
        "-"++
        show((((i div 2) -1)*3)+1)
  elseif ( i mod 2 = 0 ) /\ (( j = 3 ) \/ ( j = 4 )) /\ (((((i div 2) -1)*3)+2)>99)  /\ (((i-1)*6+j) <= students)
        then
        "-"++
        show((((i div 2) -1)*3)+2)
  elseif ( i mod 2 = 0 ) /\ (( j = 5 ) \/ ( j = 6 )) /\ (((((i div 2) -1)*3)+3)>99)  /\ (((i-1)*6+j) <= students)
        then
        "-"++
        show((((i div 2) -1)*3)+3)
  elseif ( i mod 2 != 0 ) /\ (( j = 1 ) \/ ( j = 2 )) /\ ((((((i+1) div 2) -1)*3)+1)>99)  /\ (((i-1)*6+j) <= students)
        then
        "-"++
        show(((((i+1) div 2) -1)*3)+1) 
  elseif ( i mod 2 != 0 ) /\ (( j = 3 ) \/ ( j = 4 )) /\ ((((((i+1) div 2) -1)*3)+2)>99) /\ (((i-1)*6+j) <= students)
        then
        "-"++
        show(((((i+1) div 2) -1)*3)+2) 
  elseif ( i mod 2 != 0 ) /\ (( j = 5 ) \/ ( j = 6 )) /\ ((((((i+1) div 2) -1)*3)+3)>99) /\ (((i-1)*6+j) <= students)
        then
        "-"++
        show(((((i+1) div 2) -1)*3)+3)       
        
  else ""
  endif ++
  
  
  % CREATING COLUMNS
  if (j mod 2 = 0) 
        then
        "   |"

   else "" 
  endif ++
  
  
  %ROOM NUMBER GENERATION
  %ROOM DESIGN
	if  ((i mod room_limit = 0) /\ (j = column_count) /\ (i !=row_needed) /\ ((i div room_limit)+1)!= room_used) 
	      then 
	      "\n" ++
		    "_________________________________________________________________________"++
	      "\n\n\n\n" ++
	      ">>>Room no: "++ 
	      show((i div room_limit)+1) ++
        "\n" ++
        "_________________" ++
        "\n" ++
        "Number of students: " ++
        show(student_in_each_room) ++ 
        "\n\n" ++
        "\n"++
		    "_________________________________________________________________________"++
        "\n\n" 
        
         	elseif  ((i mod room_limit = 0) /\ (j = column_count) /\ (i !=row_needed) /\ ((i div room_limit)+1) = room_used) 
	      then 
	      "\n" ++
		    "_________________________________________________________________________"++
	      "\n\n\n\n" ++
	      ">>>Room no: "++ 
	      show((i div room_limit)+1) ++
        "\n" ++
        "_________________" ++
        "\n" ++
        "Number of students: " ++
        show(student_in_last_room) ++ 
        "\n\n" ++
        "\n"++
		    "_________________________________________________________________________"++
        "\n\n"  
              
                                      
	elseif  ((j = column_count) /\ (i !=row_needed))
	      then
	      "\n" ++
	      "|                       |                       |                       |"++
	      "\n"

	elseif   ((j = column_count) /\ (i =row_needed))
		    then
		    "\n" ++
		    "_________________________________________________________________________"++
	      "\n\n\n\n\n"
	else "   " 
	endif
	
	
	%LOOP
  |	i in Row, j in Column
  
];