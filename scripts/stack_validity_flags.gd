class_name Stack_Validity_Flags

const Stack_Has_Cards = 1 << 0
const Card_Is_Numbered = 1 << 1
const Same_Deck = 1 << 2
const Card_Is_One_Less = 1 << 3
const Card_Is_One_More = 1 << 4
const Card_Is_Sakura = 1 << 5
const Card_Is_Zero = 1 << 6
const Stack_Is_Default = 1 << 7
const Stack_Is_Dragon = 1 << 8
const Stack_Is_Sakura = 1 << 9
const Stack_Is_Final = 1 << 10


const Valid_Flags: Array[int] = [
	Stack_Is_Default,
	Stack_Is_Default | Card_Is_Zero,
	Stack_Is_Default | Card_Is_Sakura,
	Stack_Is_Default | Card_Is_Sakura | Card_Is_Zero,
	Stack_Is_Default | Card_Is_Numbered,
	Stack_Is_Default | Card_Is_Numbered | Card_Is_Zero,
	Stack_Is_Default | Stack_Has_Cards | Card_Is_Numbered | Card_Is_One_Less,
	
	Stack_Is_Dragon,
	Stack_Is_Dragon | Card_Is_Zero,
	Stack_Is_Dragon | Card_Is_Numbered,
	Stack_Is_Dragon | Card_Is_Numbered | Card_Is_Zero,
	Stack_Is_Dragon | Card_Is_Sakura,
	Stack_Is_Dragon | Card_Is_Sakura | Card_Is_Zero,
	
	Stack_Is_Sakura | Card_Is_Sakura,
	Stack_Is_Sakura | Card_Is_Sakura | Card_Is_Zero,
	
	Stack_Is_Final | Card_Is_Numbered | Card_Is_Zero,
	Stack_Is_Final | Stack_Has_Cards | Card_Is_Numbered | Card_Is_One_More | Same_Deck
]
