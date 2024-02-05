if (ORACLEHUD_PB_DB_UPDATE == nil) then
    ORACLEHUD_PB_DB_UPDATE = {}
end
ORACLEHUD_PB_DB_UPDATE.s378 = function(db)
    local TEXT = ORACLEHUD_PB_CONTENTEMOTE_TEXT
    local ENUM = ORACLEHUD_PB_CONTENTEMOTE_ENUM
    db.content.petComments.s378 = {
        [ENUM.EMOTE] = {
            "Nibbles on a patch of clover.",
            "Hops in a zigzag pattern through the grass.",
            "Sniffs the air curiously.",
            "Thumps its hind leg to warn of danger.",
            "Grooms its fur with meticulous care.",
            "Leaps into a burrow for a quick retreat.",
            "Wiggles its nose inquisitively.",
            "Sprints in circles for no apparent reason.",
            "Digs a small hole to hide a secret treasure.",
            "Nudges a fellow rabbit playfully.",
            "Stands on its hind legs to get a better view.",
            "Rests in a cozy sunbeam, eyes half-closed.",
            "Balances on a fallen log like a tightrope walker.",
            "Hides in the tall grass, blending perfectly.",
            "Perches on a rock to survey the surroundings.",
            "Twitches its ears at the faintest sound.",
            "Nibbles on a juicy dandelion.",
            "Scratches its ear with a hind paw.",
            "Rolls in a dust bath to stay clean and cool.",
            "Leaps gracefully over a small stream.",
            "Hops onto a low tree branch for a new perspective.",
            "Listens to the whispers of the wind.",
            "Chews on a twig with contentment.",
            "Jumps with excitement in playful anticipation.",
            "Lays in a cozy burrow, eyes closed in relaxation.",
            "Stretches its legs, reaching out in all directions.",
            "Dances in a joyful display of bunny bliss.",
            "Hides behind a mushroom, peeking out curiously.",
            "Gnaws on a piece of bark for a quick snack.",
            "Pounces on a fallen leaf as if it's prey.",
            "Watches a passing butterfly with fascination.",
            "Hops in a zigzag pattern through the grass.",
            "Sniffs a vibrant wildflower, enjoying its scent.",
            "Listens intently to the rustling leaves above.",
            "Playfully nudges a pebble with its nose.",
            "Rolls on its back, enjoying a dust bath.",
            "Observes a group of fellow rabbits, ears alert.",
            "Chases its own shadow in a playful game.",
            "Explores a field of tall, swaying grass.",
            "Leaps with agility to clear a small rock.",
            "Watches the setting sun with a sense of wonder.",
            "Curls up in a cozy nest of soft leaves.",
            "Hops in a circle before settling down to rest.",
            "Practices its bunny hops with determination.",
            "Listens to the distant call of a fellow rabbit.",
            "Hops up to a higher vantage point for a view.",
            "Curiously investigates a fresh rabbit burrow.",
            "Balances on a log, tail twitching in concentration.",
            "Nibbles on a fragrant wild strawberry.",
            "Snuggles with another rabbit for warmth and comfort.",
            "Hops with a burst of energy, tail held high.",
            "Sits in quiet contemplation, eyes closed.",
            "Paw-taps a small pebble, sending it rolling.",
            "Watches a passing cloud, imagining shapes.",
            "Dart around in a game of rabbit tag.",
            "Pokes its head out of a rabbit hole, looking around.",
            "Bounces through a field of wildflowers in delight.",
            "Hops over a row of mushrooms in a playful display.",
            "Watches the moonrise with silent reverence.",
            "Binks joyfully, leaping into the air.",
            "Listens for the faintest rustle in the underbrush.",
            "Nuzzles a fellow rabbit in a sign of affection.",
            "Hops on a rock to get a better view.",
            "Curls up with its tail covering its nose.",
            "Sniffs a fresh trail left by another rabbit.",
            "Chases its own tail in a circle.",
            "Leaps onto a large rock to sunbathe.",
            "Watches the world go by from a hidden nook.",
            "Playfully tugs on a tuft of grass.",
            "Explores a rabbit warren with curiosity.",
            "Hops gracefully over a field of blossoming flowers.",
            "Gathers a small pile of leaves to create a cozy nest.",
            "Lays in the shade of a tree, ears relaxed.",
            "Observes the stars in the night sky, lost in thought.",
            "Bobs its head in a rhythmic, hypnotic pattern.",
            "Hops with agility to avoid a falling leaf.",
            "Grooms another rabbit as a gesture of friendship.",
            "Snuggles with a group of fellow rabbits for warmth.",
            "Curls up into a fluffy ball of bunny contentment.",
            "Watches the reflection in a tranquil pond.",
            "Hides in a bed of soft moss, invisible to passersby.",
            "Explores a thicket of bushes, ears alert.",
            "Leaps over a small rabbit-sized obstacle with ease.",
            "Listens to the soothing sounds of a babbling brook.",
            "Balances on a tree stump, surveying its domain.",
            "Nibbles on a wild carrot with enthusiasm.",
            "Sniffs the earth, detecting hidden scents.",
            "Rolls in a patch of wildflowers for a delightful aroma.",
            "Sits quietly, observing the world with calm eyes.",
            "Hops in a circle, tail bouncing with each leap.",
            "Plays a game of follow-the-leader with fellow rabbits.",
            "Watches a gentle rain shower from a cozy hideout.",
            "Darts through the grass in a game of chase.",
            "Cleans its ears with meticulous care.",
            "Snuggles with a rabbit companion in a moment of peace.",
            "Nibbles on a sweet blade of grass.",
            "Paws at a leaf, sending it twirling through the air.",
            "Lays down and enjoys a warm sunbeam on its fur.",
            "Cuddles up with a fellow rabbit for companionship.",
            "Hops through a field of fallen leaves, creating a trail.",
            "Rests beneath a tree, tail wrapped around its body.",
            "Watches a rainbow in the sky with fascination.",
            "Nibbles on a tender green shoot with delight.",
            "Sniffs a collection of vibrant flowers with curiosity.",
            "Dashes through a patch of soft, cool soil.",
            "Balances on a narrow ledge with grace and precision.",
            "Bounces through a field of tall, swaying wheat.",
            "Hides in a cozy hollow, feeling safe and secure."
        },
        [ENUM.EMOTE_SUMMON] = {
            "Yawns and stretches its fluffy paws.",
            "Blinks sleepily as it gazes around.",
            "Nuzzles its face into a cozy, warm spot.",
            "Hops to its feet with a burst of energy.",
            "Rubs its eyes with its little paws.",
            "Twitches its nose awake and alert.",
            "Curls up into a tiny, drowsy ball.",
            "Shakes off the last remnants of sleep.",
            "Wiggles its ears to shake off grogginess.",
            "Stretches its legs and arches its back.",
            "Licks its fur to make it neat and tidy.",
            "Wakes up with a hop and a joyful bounce.",
            "Listens for the sounds of the morning.",
            "Sits up and surveys its surroundings.",
            "Grooms its fur with care and precision.",
            "Nibbles on a nearby patch of greens.",
            "Hops to the entrance of its burrow.",
            "Bobs its head in a sleepy rhythm.",
            "Takes a moment to yawn and blink.",
            "Rolls onto its back and rubs its tummy.",
            "Wakes up with a little hop and a twist.",
            "Sniffs the morning air with curiosity.",
            "Sits still for a moment, ears twitching.",
            "Leaps out of its burrow with excitement.",
            "Stands on its hind legs to get a better view.",
            "Nuzzles a fellow rabbit to say good morning.",
            "Cautiously peeks out from its hiding spot.",
            "Chews on a piece of bark for breakfast.",
            "Hops over to a sunny spot to bask in warmth.",
            "Licks its front paws and washes its face.",
            "Wakes up and gives a friendly bunny nod.",
            "Snuggles with another rabbit for comfort.",
            "Stands on all fours, ready to explore.",
            "Watches the sunrise with sleepy eyes.",
            "Nudges its way out of a cozy nest.",
            "Bounces out of its burrow with a jump.",
            "Yawns and then sniffs the morning dew.",
            "Jumps up and down to wake itself up.",
            "Sits up and starts nibbling on hay.",
            "Stretches its legs and flexes its muscles.",
            "Opens its eyes and wiggles its nose.",
            "Leaps into the air with morning enthusiasm.",
            "Sniffs a fresh, cool breeze with delight.",
            "Licks its fur to get rid of sleepiness.",
            "Hops in a circle, full of energy.",
            "Twitches its ears in the morning light.",
            "Curiously explores its surroundings.",
            "Wakes up and wags its tiny tail.",
            "Stands up and surveys the world.",
            "Nuzzles a fellow rabbit to say hello.",
            "Grooms itself to look its best.",
            "Cautiously peeks outside its burrow.",
            "Hops to a sunbeam to warm up.",
            "Sits up and stretches its front paws.",
            "Yawns widely, showing off tiny teeth.",
            "Wakes up and hops with enthusiasm.",
            "Sniffs the fresh morning grass.",
            "Nudges a sleepy rabbit friend awake.",
            "Stands on its hind legs and hops around.",
            "Opens its eyes and wags its tail.",
            "Leaps into a field of fresh flowers.",
            "Wakes up and sniffs the morning air.",
            "Bounces out of bed with boundless energy.",
            "Licks its paws and cleans its whiskers.",
            "Jumps up with a burst of morning joy.",
            "Twitches its nose to wake up completely.",
            "Wiggles its ears in the dawn light.",
            "Yawns, shakes its head, and blinks.",
            "Hops into a patch of soft morning sunlight.",
            "Nuzzles a leaf to check the freshness.",
            "Wakes up and wiggles its tail in happiness.",
            "Stands on its hind legs to greet the day.",
            "Sniffs the scent of flowers in the breeze.",
            "Cautiously peeks outside to see the world.",
            "Hops over to a fellow rabbit's burrow.",
            "Licks its paws to wash its face.",
            "Rolls over and stretches all four legs.",
            "Wakes up and hops around in circles.",
            "Blinks and looks around in the morning light.",
            "Stretches its body and kicks its hind legs.",
            "Nudges a friend and shares a morning nuzzle.",
            "Jumps with excitement at the new day.",
            "Yawns, then sniffs a fragrant flower.",
            "Opens its eyes and gazes at the sky.",
            "Leaps into the day with a happy hop.",
            "Wakes up and nibbles on a fresh leaf.",
            "Twitches its whiskers to full alertness.",
            "Wiggles its tail with early morning joy.",
            "Sniffs the earth with curiosity.",
            "Stands up tall to take in the surroundings.",
            "Cautiously explores the dawn's beauty.",
            "Hops into a patch of dew-covered grass.",
            "Licks its paws and cleans its fur.",
            "Wakes up and greets the world with a hop.",
            "Grooms its fur with care and precision.",
            "Stretches its legs and arches its back.",
            "Nuzzles a fellow rabbit to say good morning.",
            "Hops to the entrance of its burrow.",
            "Bobs its head in a sleepy rhythm.",
            "Takes a moment to yawn and blink.",
            "Rolls onto its back and rubs its tummy.",
            "Wakes up with a little hop and a twist.",
            "Sniffs the morning air with curiosity.",
            "Sits still for a moment, ears twitching.",
            "Leaps out of its burrow with excitement.",
            "Stands on its hind legs to get a better view.",
            "Nuzzles a fellow rabbit to say good morning.",
            "Cautiously peeks out from its hiding spot.",
            "Chews on a piece of bark for breakfast.",
            "Hops over to a sunny spot to bask in warmth.",
            "Licks its front paws and washes its face.",
            "Wakes up and gives a friendly bunny nod.",
            "Snuggles with another rabbit for comfort.",
            "Stands up and starts nibbling on hay.",
            "Watches the sunrise with sleepy eyes.",
            "Nudges its way out of a cozy nest.",
            "Bounces out of its burrow with a jump.",
            "Yawns and then sniffs the morning dew.",
            "Jumps up and down to wake itself up.",
            "Sits up and starts nibbling on hay.",
            "Stretches its legs and flexes its muscles.",
            "Opens its eyes and wiggles its nose.",
            "Leaps into the air with morning enthusiasm.",
            "Sniffs a fresh, cool breeze."
        },
        [ENUM.SPEAK] = {
            "Carrots are the best!",
            "Hoppy to see you!",
            "I love digging burrows.",
            "Did you bring any treats?",
            "Why do birds get all the worms?",
            "Fluffy tails are in fashion.",
            "I wish I could fly like a bird.",
            "Let's play hide and seek!",
            "Chasing my shadow is fun.",
            "The grass is so tasty here.",
            "I heard there's a big carrot patch nearby.",
            "Watch out for the foxes!",
            "I'm a hopping expert!",
            "Rabbits rule, foxes drool!",
            "Let's race to the carrot patch!",
            "I'm the fastest bunny around.",
            "Sometimes I like to nap all day.",
            "What's the scoop, human?",
            "I found a four-leaf clover!",
            "Carrots are nature's candy.",
            "Bunnies love sunny days.",
            "Who's your favorite rabbit?",
            "Digging tunnels is great exercise.",
            "I'm the king of the burrow!",
            "Naptime is the best time.",
            "I'm a professional carrot muncher.",
            "Why do people say 'happy as a clam'?",
            "I'll trade you a carrot for a hug.",
            "Bouncing is my cardio.",
            "What's up, doc?",
            "I love a good head rub.",
            "The moon is my nightlight.",
            "Rabbits bring good luck, you know.",
            "If in doubt, hop it out.",
            "I've got a spring in my step.",
            "I'm a furry ball of happiness.",
            "The grass is always greener, right?",
            "I love you more than carrots!",
            "Carrot juice is my kind of juice cleanse.",
            "I've got a lucky rabbit's foot, but I still have all four!",
            "Life is one big carrot hunt.",
            "Are you a friend or a foe?",
            "I'm a burrow enthusiast.",
            "I dream of a world covered in clover.",
            "There's nothing like a good thump to get attention.",
            "Hopping is the secret to happiness.",
            "I'm a vegetarian, but I love my veggies!",
            "Chew on this: rabbits are awesome!",
            "I'm a proud member of the 'Hare Force.'",
            "My tail is my best feature.",
            "Bunny kisses are magical!",
            "Happiness is a sunny meadow.",
            "I love to nibble on herbs.",
            "What's your favorite rabbit breed?",
            "I'm the fastest carrot chomper in town!",
            "Let's play follow the leader!",
            "Carrots are the key to world peace.",
            "I love to hop through flower fields.",
            "Don't underestimate my digging skills.",
            "I believe in the power of positive hopping.",
            "I'm a fan of furry snuggles.",
            "Carrots are my one true love.",
            "I could out-hop a kangaroo any day.",
            "I wish I could join the circus!",
            "Life is a burrow of surprises.",
            "I'm a carrot connoisseur.",
            "I'm a firm believer in 'pawsitivity.'",
            "The best way to stay safe is to hide.",
            "Who needs TV when you can watch the clouds?",
            "Rain is just nature's way of giving us a bath.",
            "The more, the merrier in the rabbit world.",
            "I'm a pro at nibbling on dandelions.",
            "Bouncing is the best stress relief.",
            "I've got a nose for adventure.",
            "Bunny logic: If it fits, I sits.",
            "I'm the king (or queen) of the meadow.",
            "The world looks better from up here.",
            "I love to explore new rabbit holes.",
            "I dream of a world with endless clover fields.",
            "Every day is a new hopportunity.",
            "Carrots are my superfood.",
            "I have a strong urge to chew on everything.",
            "I'll take a field of clover over a red carpet any day.",
            "I'm a hopaholic, and I'm proud of it!",
            "I'm all ears... literally.",
            "Hopping through life one day at a time.",
            "I'm a hay connoisseur.",
            "Who needs an alarm clock when you have birds?",
            "I love to play 'guess that herb.'",
            "I'm a believer in the power of fluffy tails.",
            "Bunnies make everything better.",
            "If you're happy and you know it, give me a carrot!",
            "Carrots: the original power food.",
            "A burrow is a rabbit's best friend.",
            "I'm all about that carrot life.",
            "I'm the life of the bunny party!",
            "Rabbits are the real gardeners of the world.",
            "I love to groom my fur to perfection.",
            "I'm an expert at wiggling my nose.",
            "Bunnies know how to have a hopping good time.",
            "Happiness is a binkying bunny.",
            "I wish I could share my carrots with the world.",
            "I'm a pro at finding the comfiest spot in the meadow.",
            "Let's hop into the unknown together!",
            "Bunnies have the best fluffy tails, don't you think?",
            "A thump a day keeps the foxes away.",
            "Napping is an art form I've mastered.",
            "I'm a hop-hop-hopping machine!",
            "The carrot patch is calling my name.",
            "I love you more than a basket of fresh herbs.",
            "Life is full of surprises, especially in the burrow.",
            "I believe in the magic of bunny kisses."
        },
        [ENUM.SPEAK_WIN] = {
            "Victory is ours, my furry friends!",
            "We hopped to victory and conquered all!",
            "The carrot of triumph is ours!",
            "Carrots for all the brave bunnies!",
            "Our warren stands strong and victorious!",
            "We proved that size doesn't matter!",
            "Hop, hop, hooray!",
            "The sweet taste of victory is like a carrot!",
            "We're the champions of the meadow!",
            "The grass is greener on our side!",
            "Rabbits unite! We are unbeatable!",
            "Even the foxes couldn't stop us!",
            "Hippity hoppity, we won the battle!",
            "Victory is as sweet as clover!",
            "We're the bounciest warriors in the land!",
            "Carrots and triumph are our rewards!",
            "Our warren is the mightiest of them all!",
            "We hopped, we fought, we conquered!",
            "Rabbit power reigns supreme!",
            "Our fluffy tails never surrendered!",
            "We outsmarted our enemies with carrots!",
            "Hop to the beat of victory!",
            "No foe can match our rabbit valor!",
            "Carrots for courage, we're unstoppable!",
            "The world bows to the mighty rabbits!",
            "Hurray for the bunnies! We did it!",
            "Our victory dance is full of binkies!",
            "We're the hopping heroes of the day!",
            "No one can resist the power of bunnies!",
            "The battle is won, and carrots await!",
            "We're the true champions of the meadow!",
            "Hop-hop-hooray! We're the winners!",
            "The meadow is safe in our paws!",
            "Carrots and glory are our destiny!",
            "We showed them what it means to be a rabbit!",
            "Our warren is the epitome of unity!",
            "Hopping is our secret weapon!",
            "Bunny power prevails!",
            "We fought for carrots and won the day!",
            "Our victory is as bright as a full moon!",
            "We're the bounciest brigade in history!",
            "We're the rabbits who conquer it all!",
            "Carrots, clover, and conquest!",
            "Victory is a hop, skip, and jump away!",
            "Carrots are the fuel of champions!",
            "Hop on, fellow rabbits, to more victories!",
            "We're the true rulers of the meadow!",
            "We defended our burrows with valor!",
            "Carrots are our war cry!",
            "Hop to the top! We are invincible!",
            "Our ears are filled with cheers of triumph!",
            "Bunnies bring peace through victory!",
            "We hopped to victory and beyond!",
            "The bunnies are unstoppable!",
            "We're the champions of the hopping world!",
            "Carrots and courage make us legends!",
            "The meadow belongs to the rabbits!",
            "We defended our territory with honor!",
            "Bunny warriors, never back down!",
            "The battlefield is our hopscotch court now!",
            "Hop-hop-hooray for the rabbit army!",
            "The carrot of victory is ours!",
            "We're the top bunnies in the land!",
            "We left our paw prints on history!",
            "The meadow is our playground!",
            "Carrots and conquest go hand in paw!",
            "Hop for joy, for we are triumphant!",
            "We're the hopping heroes of the day!",
            "Our bravery is boundless as the meadow!",
            "Carrots are the secret to our strength!",
            "We're the rulers of the rabbit realm!",
            "Hop to it, for we've conquered all!",
            "We're the heroes the meadow deserves!",
            "Carrots and courage, our motto!",
            "Rabbits never surrender!",
            "We're the kings and queens of the meadow!",
            "The world bows to the bunny warriors!",
            "Our warren is the mightiest of all!",
            "We hopped to victory with style!",
            "Carrots and celebration await us!",
            "Hop, hop, hooray for the rabbit army!",
            "We're the bounciest battlers in town!",
            "Our determination led us to triumph!",
            "Rabbit power is unstoppable!",
            "We're the champions of the fluffy tails!",
            "The meadow will forever remember us!",
            "Carrots and camaraderie win the day!",
            "Hop-hop-hooray for the bunny brigade!",
            "We're the conquerors of the carrot kingdom!",
            "We fought valiantly for our home!",
            "Carrots and cheers, we are the champions!",
            "We're the bravest bunnies in the land!",
            "Our hearts are as big as our ears!",
            "Victory tastes like a carrot buffet!",
            "We're the hopping legends of the meadow!",
            "Carrots and celebration are our rewards!",
            "Hop to the rhythm of triumph!",
            "We defended our homeland with pride!",
            "Our warren is the envy of all!",
            "Carrots are the key to our success!",
            "Hoppity-hooray for the victorious rabbits!",
            "We're the masters of the meadow!",
            "The meadow is our playground, forever!",
            "Carrots and courage, the rabbit way!",
            "Hop-hop-hooray for the rabbit champions!",
            "We're the conquerors of the great carrot patch!",
            "We emerged victorious with fluffy tails held high!",
            "Carrots and conquest lead to celebration!",
            "We hopped, we fought, and we conquered!",
            "The meadow celebrates our rabbit triumph!",
            "Rabbit power knows no bounds!",
            "We're the hopping heroes of the hour!",
            "Our courage is as strong as our back legs!",
            "Carrots and camaraderie, we did it!",
            "Hurray for the fluffy-tailed champions!",
            "We're the champions of the bunny world!",
            "Our warren stands as a testament to victory!"
        },
        [ENUM.SPEAK_LOSS] = {
            "I hope my bunny friends find comfort.",
            "May my spirit find peace in the meadow.",
            "Remember the joy we shared.",
            "I'll always watch over you from the stars.",
            "The meadow won't be the same without me.",
            "Cherish the memories of our hops.",
            "My love for you will never fade.",
            "I'll wait for you at the rainbow bridge.",
            "May my spirit find a burrow in the sky.",
            "The carrots in bunny heaven are delicious.",
            "I'll miss the warmth of the sun on my fur.",
            "My spirit will always be in the meadow.",
            "I'll be your guardian bunny angel.",
            "Life was a grand adventure.",
            "The meadow is now my eternal home.",
            "Thank you for all the love and care.",
            "I'll be your invisible snuggle buddy.",
            "Hop to the rhythm of our happy memories.",
            "You were my favorite hooman.",
            "I'll be the twinkle in the night sky.",
            "The meadow will forever remember me.",
            "Don't be sad; remember the joy we shared.",
            "My spirit will always dance with you.",
            "Binky in my memory, my friends.",
            "I was the luckiest bunny to have you.",
            "The meadow will miss my binkies.",
            "I'll be the gentle breeze on your face.",
            "Find peace in the beauty of the meadow.",
            "My heart will forever belong to you.",
            "I'll be the guardian of our warren.",
            "May you always find carrots of happiness.",
            "My spirit lives on in your heart.",
            "I'll be the whisper in the leaves.",
            "Hop to the rhythm of our shared love.",
            "Thank you for the warmth of your love.",
            "My memory will always bring you comfort.",
            "I'll watch over our favorite clover patch.",
            "In your memories, I'll always be near.",
            "Bunny hugs and kisses from the sky.",
            "I was blessed to be part of your life.",
            "My spirit will be the morning dew.",
            "The meadow is where I'll find peace.",
            "I'll be your forever snuggle bunny.",
            "Remember the joy of our days together.",
            "The meadow will miss my happy hops.",
            "I'll be the moonlight in your dreams.",
            "My spirit will forever roam the meadow.",
            "I'll be your invisible tail-wiggler.",
            "Cherish the bond we had, my dear hooman.",
            "I'll be the sunbeam on your face.",
            "May our love echo through the meadow.",
            "I'm the guardian of our memories.",
            "I'll be the rainbow after the storm.",
            "Find peace in the magic of the meadow.",
            "Remember the way we hopped together.",
            "I'll be the song in your heart.",
            "Bunny kisses from the meadow above.",
            "I'm grateful for the life we shared.",
            "I'll be the gentle rain in the garden.",
            "Happiness is remembering our times together.",
            "My spirit dances in the meadow's breeze.",
            "I'll be the cozy burrow in your dreams.",
            "The meadow is my eternal playground.",
            "In your heart, my memory will live on.",
            "I'll be the twinkle in your fondest memories.",
            "Bunny love endures beyond the meadow.",
            "Thank you for filling my life with joy.",
            "I'll be the warmth of love in your heart.",
            "Remember the bunny wiggles we shared.",
            "Hop to the rhythm of our shared laughter.",
            "My spirit finds peace in the meadow's embrace.",
            "I'll be the guardian of our warren's burrows.",
            "In your dreams, we'll hop together.",
            "My memory will be your eternal treasure.",
            "I'll be the guardian of your dreams.",
            "Cherish the binkies we had, my dear hooman.",
            "May the meadow bring you endless solace.",
            "Bunny love is the brightest star.",
            "My spirit dances with the wildflowers.",
            "I'll be the guardian of our shared adventures.",
            "In your heart, my memory will always hop.",
            "Remember the carrots we enjoyed together.",
            "I'll be the moonlight in your fondest dreams.",
            "Thank you for being my forever hooman.",
            "My spirit will be your eternal companion.",
            "I'll be the whisper in the night breeze.",
            "Hop in my memory, my dear friends."
        }
    }
end
