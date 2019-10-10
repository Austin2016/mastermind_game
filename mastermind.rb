class Computer
  

  def gen_code(code_length,color_options)
   
    random_code = Array.new(code_length) {|i| i = color_options[ rand(color_options.length) ] }
    random_code.join
  end

 
  
  def find_best_guess(model)
    best_guess = []
    best_guess_feedback = 0
    search_length = model.current_round - 1  
    for i in 0..search_length 
      next_guess = []
      next_guess<< model.get_guess(i)
      next_guess_feedback = model.calculate_feedback(next_guess[0],model.code).count("b") + (model.calculate_feedback(next_guess[0],model.code).count("w") * 0.2) 
      if next_guess_feedback >= best_guess_feedback || i == 0
        best_guess = next_guess
        best_guess_feedback = next_guess_feedback
      end 
    end
    best_guess 
  end 

  def make_guess(model)
    length = model.params.code_length
    options = model.params.color_options
    if model.current_round == 0  
      guess_array = Array.new(length) {|i| i = options[ rand(options.length) ] }
      return  guess_array.join 
    else 
      best_guess = find_best_guess(model)[0]
      randomizer = [0,1,2,3].shuffle 
      i=0
      guess_array=["blank","blank","blank","blank"]
      b_count = model.calculate_feedback(best_guess,model.code).count("b")
      w_count = model.calculate_feedback(best_guess,model.code).count("w")
      
      b_count.times do     #remind how good guess is
        guess_array[randomizer[i]] = best_guess[randomizer[i]]
        i+=1 
      end
      rest_guess = best_guess.split("")
      for j in 0..(i-1)
        rest_guess.delete_at(randomizer[j])
      end 
      w_count.times do 
        temp = rest_guess.shuffle
        guess_array[randomizer[i]] = temp[0]
        temp.delete_at(0)    
        i+=1 
      end 
      until i == 4 
        guess_array[randomizer[i]] = options[ rand(options.length) ] 
        i+=1 
      end 
    end  
    return guess_array.join 
  end 

  






end 

class ViewDrawer  #board UI 


  def self.draw_board(model)#board_array,feedback_array,round) # shold take the model class  
    puts " "
                       
    for row in 0..model.params.max_rounds - 1
      if row <= model.current_round - 1 
        guess = model.get_guess(row)
        feedback = model.calculate_feedback( guess,model.code)
        is_current = row == model.current_round
        self.print_row( guess, feedback, is_current)
      else
       self.print_row("o"*model.params.code_length, "o"*model.params.code_length, false)
      end             
    end
     puts " "
  end 

private 

  def self.print_row(guess,feedback,current) 
   # needs guess, feedback, and to know if it's the current row 
    indent = "      "
    marker = "   >  "
    if current               
      print marker                          
    else 
      print indent 
    end        
    for col in 0..guess.length - 1                
      print guess[col]
      if col != guess.length - 1    
        print "|"
      end 
    end
    print "   " + feedback + "\n\n"    
  end 
end 

class ViewDialogue
   
   
  def self.input_guess(code_length,color_options)
    guess_prompt
    get_input(code_length,color_options) 
  end

  def self.input_code(code_length,color_options)
    code_prompt
    get_input(code_length,color_options) 
  end 

  
  def self.input_game_type  
    puts "Do you want to be the code breaker or code setter?"
    puts "click 1 for code breaker and 2 for code setter"
    
    test = true 
    
    while test
      answer = gets.chomp.to_i
      if answer == 1 || answer == 2
        test = false 
      end 
    end 
    if answer == 1 
      return "computer is code setter"
    else 
      return "computer is code breaker"
    end 
    
  end 
  def self.game_over(model)
    if model.code_broken?
      return "Code Broken!!! game over, code setter got #{model.score} points!"
    else 
      return "game over on rounds!, code setter got #{model.score} points!"
    end 
 
  end 

   def self.pause 
      puts "hit enter to continue"
      x = gets.chomp 
   end

private 

 def self.guess_prompt  #what happens when it returs nothing to a function ?????? code setter
    puts "Guess the Code! Choose 4 from the following colors: r,g,b,v,p,y or 'o' for blank"    
 end 

  def self.code_prompt
    puts "MAKE the Code! Choose 4 from the following colors: r,g,b,v,p,y or 'o' for blank"
  end 

 def self.get_input(code_length,color_options)
    test = true 
    while test 
      input = gets.chomp.split("")
      if input.all? {|e| color_options.include?(e)} && input.length == code_length
        test = false 
      else 
        puts "please try again, no spaces, and choose correct valuees!"
      end 
    end
    input.join 
  end
end 


class Parameters 
  attr_reader :code_length, :max_rounds

  def initialize (length,colors,rounds)
    @code_length = length
    @color_options = colors
    @max_rounds = rounds 
  end 
  
  def self.default_params
    Parameters.new(4,["r","g","b","v","p","y","o"],12)               
  end 

  def color_options
    @color_options.clone
  end 

end 


class GameModel 


  def initialize(code, params) #trusting that you're getting valid inputs, sanity check inputs
    #is params of type parameters ? 
    # is code of type of string 
    # is the length of code = to params.codelength
    # is every character in code in params.color_options 
    @code = code                
    @params = params           
    @guesses = []
  end 

  def code
    @code.clone 
  end 

  def params  # why do we have this ?
    @params
  end

  def add_guess(guess)  
  # is guess a string 
  # is guess = to params.codelength 
  # is every character in guess also in params.color_options 
  # is game not over ? 
  @guesses<<guess 
  end 

  def get_guess (index) 
    #round is integer 
    @guesses[index].clone 
  end 
 
  
  def code_broken? 
  # is any guess equal to the secret code ?
  @guesses.any?{|e| e == @code}
  end  

  def game_over? #if rounds get to 12 
   self.code_broken? || self.current_round == params.max_rounds  
  end 

  def current_round
    @guesses.length 
  end 

  def calculate_feedback (guess,code)
    feedback = []
    matches = Hash.new    
    for i in 0..(params.code_length - 1) 
      matches[guess[i]] = code.count(guess[i]) < guess.count(guess[i]) ? code.count(guess[i]) : guess.count(guess[i])
    end 
    for i in 0..(params.code_length - 1)            
      if guess[i] == code[i]    #decrement for each one matching index as well 
        feedback<<"b"
        matches[guess[i]]-=1
      end 
    end
    (matches.values.inject(0) {|sum,e| sum += e}).times do    #count the rest and put w for the rest 
      feedback<<"w" 
    end
    until feedback.length == @params.code_length     #fill up the feedback array 
      feedback<<"o"
    end  
    feedback.join 
  end 
  
  def score 
    if self.code_broken?
      return current_round
    elsif self.game_over? 
      return self.current_round + 1 
    else 
      return 0 
    end
  end

end 

class User 

  
  def gen_code (code_length, color_options)
    return ViewDialogue.input_code(code_length, color_options) 
  end

  def make_guess (model)
    return ViewDialogue.input_guess(model.params.code_length, model.params.color_options) 
  end 

end 

#NEW MAIN 

  params = Parameters.default_params
  comp = Computer.new
  user = User.new 

  game_type = ViewDialogue.input_game_type

  if game_type == "computer is code setter" 
    code_setter = comp 
    code_breaker = user 
  elsif game_type == "computer is code breaker"
    puts game_type
    code_setter = user
    code_breaker = comp 
  end 

  code = code_setter.gen_code( params.code_length,params.color_options )
  model = GameModel.new(code,params)
  ViewDrawer.draw_board(model)

  until model.game_over?
    guess = code_breaker.make_guess(model)
    model.add_guess( guess )
    ViewDrawer.draw_board(model)
    if game_type == "computer is code breaker"  
      ViewDialogue.pause
    end 
  end   
    
  puts ViewDialogue.game_over(model) 
 



#main 
=begin
params = Parameters.default_params
board = ViewDrawer.new
dialogue = ViewDialogue.new 
comp = Computer.new

game_type = dialogue.input_game_type

if game_type == "computer is code setter" 
  computer_code = comp.gen_code( params.code_length,params.color_options )
  model = GameModel.new(computer_code,params)
  board.draw_board(model)

  until model.game_over?
    user_guess = dialogue.input_guess(params.code_length,params.color_options)
    model.add_guess( user_guess )
    board.draw_board(model)
  end   
  
  puts dialogue.game_over(model) 

elsif game_type == "computer is code breaker"
  user_code = dialogue.input_code(params.code_length,params.color_options)  
  model = GameModel.new( user_code,params )
  board.draw_board(model)
 
  until model.game_over?
    model.add_guess( comp.comp_guess(model) )
    board.draw_board(model)
    dialogue.pause
  end
  puts dialogue.game_over(model) 
end   
=end 













=begin

class ViewDrawer  #board UI 
                  
  def draw_board(model)#board_array,feedback_array,round) # shold take the model class  
  	puts " "                    
	  for row in 0..11
	    if row == model.round - 1   
	      print "   >  "
	    else 
	      print "      "
	    end  	     
	    for col in 0..3
		    #print board_array[row * 4 + col ]         # numbers show the user what keys to hit to place a letter
		    print model.get_board_piece(row * 4 + col)
        if col !=3 
		      print "|"
		    end 
	    end
	    print "   "
	    for col in 0..3
	     #print feedback_array[ ( row * 4) + col ]
        print model.get_feedback_piece (row * 4 + col)
	    end 
	    print "\n"
	    if row !=11
	      print"     -------\n"
	    end 
      end
     puts " "
  end 
end

class ViewDialogue 
  
  def guess_prompt  #what happens when it returs nothing to a function ?????? code setter
  	  puts "Guess the Code! Choose 4 from the following colors: r,g,b,v,p,y or 'o' for blank"
  	  get_input  
  end 

  def code_prompt
  	    puts "MAKE the Code! Choose 4 from the following colors: r,g,b,v,p,y or 'o' for blank"
  	    get_input
  end 

  def get_input
  	test = true 
	  while test 
      input = gets.chomp.split("")
	    if input.all? {|e| ["r","g","b","v","p","y","o"].include?(e)} && input.length == 4
	      test = false 
	    else 
		    puts "please try again, no spaces, and choose correct valuees!"
	    end 
    end
    input
  end 

  
  def game_type_prompt 
  	puts "Do you want to be the code breaker or code setter?"
  	puts "click 1 for code breaker and 2 for code setter"
  	
  	test = true 
  	
  	while test
  	  answer = gets.chomp.to_i
  	  if answer == 1 || answer == 2
  	    test = false 
  	  end 
   	end 
   	
   	answer 
  end 

  

end 

class GameModel 
  
  attr_reader :round 

  def initialize 
  	@board = Array.new(48) {|i| i = "o" } 
  	@feedback = Array.new(48) {|i| i = "o" }   
  	@code_options = ["r","g","b","v","p","y","o"] # is blank  
  	@round = 0
                  
  end
  
  def game_type(input)
    if input == 1
      @computer = "code_setter"
      return @computer  
    else
      @computer = "code_breaker"
      return @computer
    end 
  end 
  
  def set_code(view)
	   if @computer == "code_setter"
	     @code = Array.new(4) {|i| i = @code_options[ random(@code_options.length) ] }
	   elsif @computer =="code_breaker" 
	   	@code = view.code_prompt  
	   end
  end

  

  def set_guess(view,comp_guess)
    if @computer == "code_setter"
      @guess = view.guess_prompt 
    elsif @computer == "code_breaker"
      @guess = comp_guess
    end 
  end
 

  def update_round
    @round+=1
  end 

  def random(n)
    ((rand()*n).ceil) - 1  # returns 0 through n-1 randomly 
  end

  def update_board#(array,round) 
    for i in 0..3
      @board[ ( (@round - 1) * 4) + i] = @guess[i]
    end
    
  end

  def update_feedback (array)#,round) 
    for i in 0..3
      @feedback[ ((@round-1) * 4) + i ]  = array[i]
    end 
  end 
  

  def game_over?(f)
    if f.all?{|e| e == "b"}
      return true     
    elsif @round == 12
      return true 
    else 
      return false 
    end
    
  end 
 
  def score 
    if @round == 12 && [ @feedback[-1], @feedback[-2], @feedback[-3], @feedback[-4] ]!=["b","b","b","b"]           #actually the computer gets 12 points + 1 for the user not guessing
      puts "code maker got 13 points !"
    else 
      puts "code maker got #{@round } points"
    end  
    
  end 

  def find_best_guess
    best_guess = []
    best_guess_feedback = 0
    search_length = ( @round -2 ) 
    for i in 0..search_length 
      next_guess = []
      for j in 0..3
        next_guess<< @board[ (i * 4) + j ]
        next_guess_feedback = self.calculate_feedback(next_guess,@code).count("b") + (self.calculate_feedback(next_guess,@code).count("w") * 0.2) 
      end
      if next_guess_feedback >= best_guess_feedback || i == 0
        best_guess = next_guess
        best_guess_feedback = next_guess_feedback
      end 
    end
    best_guess
  end 

  def comp_guess
    if @round == 1  
      guess_array = Array.new(4) {|i| i = @code_options[ random(@code_options.length) ] }
      return  guess_array 
    else 
      best_guess = find_best_guess
      randomizer = [0,1,2,3].shuffle 
      i=0
      guess_array=["blank","blank","blank","blank"]
      b_count = self.calculate_feedback(best_guess,@code).count("b")
      w_count = self.calculate_feedback(best_guess,@code).count("w")
      
      b_count.times do     #remind how good guess is
        guess_array[randomizer[i]] = best_guess[randomizer[i]]
        i+=1 
      end
      rest_guess = best_guess
      for j in 0..(i-1)
        rest_guess.delete_at(randomizer[j])
      end 
      w_count.times do 
        temp = rest_guess.shuffle
        guess_array[randomizer[i]] = temp[0]
        temp.delete_at(0)    
        i+=1 
      end 
      until i == 4 
        guess_array[randomizer[i]] = @code_options[ random(@code_options.length) ] 
        i+=1 
      end 
    end  
    return guess_array
  end 
      

   


  def calculate_feedback (guess=@guess,code=@code)
  	feedback = []
  	count = Hash.new    
  	for i in 0..3         # find all the matches between guessed colors and colors in answer 
  		count[guess[i]] = code.count(guess[i]) < guess.count(guess[i]) ? code.count(guess[i]) : guess.count(guess[i])
  	end 
    for i in 0..3            
      if guess[i] == code[i]    #decrement for each one matching index as well 
  	    feedback<<"b"
  	    count[guess[i]]-=1
  	  end 
  	end
  	(count.values.inject(0) {|sum,e| sum += e}).times do    #count the rest and put w for the rest 
  	  feedback<<"w" 
  	end
  	until feedback.length == 4     #fill up the feedback array 
  	  feedback<<"o"
  	end  
    feedback 
  end 
  
  def pause 
  	if @computer == "code_breaker"
      puts "hit enter to continue"
      x = gets.chomp
    end 
  end 

  def get_board_piece(p)
    @board[p]
  end

  def get_feedback_piece(p)
    @feedback[p]
  end 


end

=end 

#main 

=begin my original main  

graphics=ViewDrawer.new
model=GameModel.new
dialogue =ViewDialogue.new 

model.game_type(dialogue.game_type_prompt) # asks user if they want to be code breaker/setter 
model.set_code( dialogue ) 

feedback = [false]                          # need feedback to not be nil and to be falsey 
until model.game_over?(feedback) == true  
  
  model.update_round 

  graphics.draw_board( model )
  
  puts  "round #{model.round} " 
  
  model.pause 
   
  print " \n"
  
  model.set_guess( dialogue , model.comp_guess ) #(model.round) )                  #guess made 
  
  model.update_board#(model.get_guess, model.round)      #board state updated 
  
  feedback = model.calculate_feedback#( model.get_guess, model.get_code)   #feedback state updated 
  
  model.update_feedback(feedback)#,model.round)            #feedback state updated
    
end

graphics.draw_board( model )

puts "the game is over!" 
puts " #{model.score}"

=end #my original main 


#bug if i set code to oooo DONE 
#says computer got x points after done guessing but is that correct ? DONE  
#find if the behavior is correct if you win on last turn: specifically the scoring behavior DONE 

#make a class that has game paramaters: total turns, colors, code_length
#game model needs to know code length, set of colors, and number of turns 
#it gets these from another class (parameter class) and gets them at initialization 

#make Game model have  3 @ variables...game parameters, secret code a string, and set of guesses ( array of strings)
#think of a class as some data that you can't see and some methods to manipulate it 
#throw exceptions if parameter inputs in initialize are correct 
#computer class makes a code, or makes a guess .... 
#you have to give the computer the game model 

