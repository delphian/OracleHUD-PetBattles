if (ORACLEHUD_PB_DB_UPDATE == nil) then
    ORACLEHUD_PB_DB_UPDATE = {}
end
ORACLEHUD_PB_DB_UPDATE.s379 = function(db) 
    db.content.petComments.s379 = function(db, type)
        local comment = nil
        local collection = nil
        if (type == nil) then
            type = "speak"
        end
        local emote = {
            "Nimbly climbs a tree trunk with acrobatic finesse.",
            "Scampers across the forest floor in a playful dance.",
            "Chitters softly, communicating with fellow squirrels.",
            "Leaps from branch to branch, traversing the treetop realm.",
            "Gathers acorns and stores them in a secret stash.",
            "Balances on hind legs, surveying the woodland expanse.",
            "Nuzzles into the softness of a mossy tree trunk.",
            "Perches on a rock, keeping a watchful eye on the surroundings.",
            "Twirls its fluffy tail like a propeller for added cuteness.",
            "Scurries through a pile of leaves, creating a rustling spectacle.",
            "Hops in a zigzag pattern, showcasing nimble agility.",
            "Grooms its fur with meticulous care, maintaining pristine fluffiness.",
            "Sniffs the air with curiosity, detecting scents on the breeze.",
            "Nestles into a cozy nest of leaves, creating a squirrel sanctuary.",
            "Chirps loudly to warn of potential dangers in the vicinity.",
            "Hops onto a fallen log, using it as a woodland runway.",
            "Dances a lively jig, celebrating the joy of squirrel existence.",
            "Hides in the shadows, observing the forest with keen eyes.",
            "Snacks on a nut with voracious nibbles, enjoying the woodland feast.",
            "Darts through a thicket, leaving a trail of rapid movement.",
            "Curls into a fluffy ball, resembling a miniature woodland cushion.",
            "Sits still, blending into the surroundings with expert camouflage.",
            "Performs acrobatic flips on a tree branch, a squirrel gymnast.",
            "Snuggles with a fellow squirrel, sharing warmth in the treetop community.",
            "Hops onto a mushroom, using it as a makeshift woodland podium.",
            "Gnaws on a pinecone, mastering the art of woodland cuisine.",
            "Climbs to the top of a tree, claiming the highest vantage point.",
            "Rolls in a pile of leaves, reveling in the autumnal carpet.",
            "Darts through a network of vines, mastering the jungle of branches.",
            "Chuckles softly, expressing squirrel amusement with a gentle sound.",
            "Hops onto a boulder, surveying the landscape like a tiny monarch.",
            "Nestles into a bed of flowers, enjoying the fragrance of the bloom.",
            "Balances on a slender branch, defying gravity with squirrel finesse.",
            "Sniffs a patch of moss, checking for any hidden woodland treasures.",
            "Flicks its tail in delight, creating a mesmerizing pattern of movement.",
            "Leaps onto a tree stump, claiming it as a regal squirrel throne.",
            "Nibbles on a leaf with dainty bites, savoring the woodland delicacy.",
            "Dances on its hind legs, twirling with the grace of a woodland ballerina.",
            "Hops between rocks, navigating the rocky terrain with ease.",
            "Nudges a pinecone, considering it as a potential playmate.",
            "Gathers twigs and leaves for nest-building in a flurry of activity.",
            "Chases its own shadow, engaging in a whimsical woodland game.",
            "Leaps onto a fallen log, using it as a squirrel balance beam.",
            "Rolls a small pebble with its nose, playing a game of woodland soccer.",
            "Bounces off a tree trunk, demonstrating the springiness of a well-rested squirrel.",
            "Chirrups in greeting to a passing bird, engaging in woodland communication.",
            "Leaps from tree to tree, tracing a path among the treetop giants.",
            "Sits on a sunlit branch, soaking in the warmth with contentment.",
            "Flicks its tail in a pattern, creating a Morse code message for the woodland.",
            "Perches on a mushroom, using it as a squirrel pedestal for contemplation.",
            "Nudges a pebble with its nose, investigating woodland mysteries on the forest floor.",
            "Darts through a patch of ferns, a blur of energy in the greenery.",
            "Chatters with a fellow squirrel, exchanging news in the treetop community.",
            "Grooms its tail meticulously, ensuring it's ready for the day's adventures.",
            "Scampers in a figure-eight pattern, tracing the infinity of woodland possibilities.",
            "Nuzzles a nearby flower, savoring the fragrance of the early bloom.",
            "Leaps onto a tree stump, striking a triumphant pose in the woodland arena.",
            "Chirrups in delight, sharing the news of the new day with the forest.",
            "Glides between branches, a silent shadow in the waking woodland.",
            "Nestles into a bed of leaves, savoring the softness of the forest bed.",
            "Scurries along a fallen log, balancing with woodland grace.",
            "Chases its own tail, caught in a playful morning spiral of energy.",
            "Snacks on a leftover acorn, savoring the tasty remnants from dreams.",
            "Waves its tail in greeting, acknowledging the day with squirrelly flair.",
            "Nudges a pinecone, considering it as a potential morning toy.",
            "Hops onto a fallen log, using it as a morning balance beam.",
            "Darts through a tangle of vines, mastering the art of morning navigation.",
            "Chatters animatedly, recounting the night's adventures to the waking world.",
            "Perches on a branch, watching the forest awaken with watchful eyes.",
            "Flicks its tail in Morse code, sending secret morning messages to the woodland.",
            "Sprints along a branch, testing the speed of its morning locomotion.",
            "Nibbles on a leaf, contemplating the mysteries hidden within the greenery.",
            "Bounces on its hind legs, a joyful display of morning exuberance.",
            "Chirrups in greeting to a passing bird, engaging in morning woodland dialogue.",
            "Leaps from tree to tree, tracing a morning path among the waking giants.",
            "Sits on a sunlit branch, soaking in the morning rays with contentment.",
            "Flicks its tail in a pattern, creating a Morse code message for the morning.",
            "Perches on a mushroom, using it as a morning pedestal for woodland contemplation.",
            "Nudges a pebble with its nose, investigating morning mysteries on the forest floor.",
            "Darts through a patch of ferns, a blur of morning energy in the greenery.",
            "Chatters with a fellow squirrel, sharing morning gossip in the treetop community.",
        }
        local emote_summon = {
            "Stretches each paw and tail in a sleepy daze.",
            "Yawns widely, showcasing tiny, sharp teeth.",
            "Shakes off imaginary sleep leaves from fur.",
            "Rubbing its eyes with tiny, fuzzy paws.",
            "Wiggles its nose, sniffing the fresh morning air.",
            "Grooms its fluffy tail with meticulous care.",
            "Hops from one paw to another, warming up for the day.",
            "Twirls in a playful circle, still half in dreamland.",
            "Nuzzles into the cozy embrace of its bushy tail.",
            "Sniffs the surroundings, checking for any nighttime visitors.",
            "Balances on hind legs, surveying the waking forest.",
            "Dances a quick jig, celebrating the return to the waking world.",
            "Chitters softly, exchanging morning greetings with fellow squirrels.",
            "Nestles into the crook of a branch, savoring the last moments of sleep.",
            "Gazes at the sunrise, marveling at the changing colors of the sky.",
            "Hops from branch to branch, testing its agility after a night's rest.",
            "Savors the morning dew on its whiskers, quenching its thirst.",
            "Leaps into a nearby tree, eager to explore the waking forest.",
            "Scratches behind its ears, enjoying a satisfying morning scratch.",
            "Nudges a fallen acorn, wondering if it's a leftover dream snack.",
            "Chases its tail in a playful spiral of morning exuberance.",
            "Peeks out from its nest, blinking away the last remnants of sleep.",
            "Inspects its surroundings with curious, beady eyes.",
            "Gathers a few leaves for a makeshift morning nest adjustment.",
            "Gently nibbles on a twig, tasting the flavors of the dawn.",
            "Rolls on its back, reveling in the warmth of the morning sun.",
            "Scampers up and down a tree trunk, testing its agility.",
            "Sniffs the forest floor, checking for any interesting scents.",
            "Darts from branch to branch, a streak of fur in the awakening canopy.",
            "Chirps a cheerful morning melody, announcing its wakefulness.",
            "Nudges a fellow squirrel, inviting it to join in the morning festivities.",
            "Flicks its tail in rhythmic beats, setting a morning tempo.",
            "Gazes at the sky, contemplating the mysteries of the waking world.",
            "Dangles upside down from a branch, savoring the upside-down view.",
            "Gnaws on a twig, perhaps the remnants of a dream tree branch.",
            "Hops in a zigzag pattern, tracing imaginary trails of nocturnal adventures.",
            "Pokes its head out from a leafy cover, surveying the dawn scene.",
            "Snuggles into a sunbeam, absorbing the warmth of the early sunlight.",
            "Chases a phantom insect, still caught in the dream of nighttime pursuits.",
            "Nimbly navigates a maze of branches, relishing the morning maze.",
            "Sits still for a moment, soaking in the symphony of the awakening forest.",
            "Chuckles softly, as if sharing a secret with the morning breeze.",
            "Pirouettes on a slender branch, performing a ballet of morning joy.",
            "Hops onto a rock, using it as a morning podium for a moment of reflection.",
            "Nestles into the leaves, basking in the comforting scent of the forest floor.",
            "Sniffs a patch of moss, checking for any hidden morning treasures.",
            "Bounces from tree to tree, leaving behind a trail of morning excitement.",
            "Grooms its tail meticulously, ensuring it's ready for the day's adventures.",
            "Scampers in a figure-eight pattern, tracing the infinity of morning possibilities.",
            "Nuzzles a nearby flower, savoring the fragrance of the early bloom.",
            "Leaps onto a tree stump, striking a triumphant morning pose.",
            "Chirrups in delight, sharing the news of the new day with the forest.",
            "Glides between branches, a silent shadow in the waking woodland.",
            "Nestles into a bed of leaves, savoring the softness of the forest bed.",
            "Scurries along a fallen log, balancing with morning grace.",
            "Chases its own shadow, engaged in a playful morning game.",
            "Snacks on a leftover acorn, a tasty remnant from the dreamscape.",
            "Waves its tail in greeting, acknowledging the day with squirrelly flair.",
            "Nudges a pinecone, considering it as a potential morning toy.",
            "Hops onto a fallen log, using it as a morning balance beam.",
            "Darts through a tangle of vines, mastering the art of morning navigation.",
            "Chatters animatedly, recounting the night's adventures to the waking world.",
            "Perches on a branch, watching the forest awaken with watchful eyes.",
            "Flicks its tail in Morse code, sending secret morning messages to the woodland.",
            "Sprints along a branch, testing the speed of its morning locomotion.",
            "Nibbles on a leaf, contemplating the mysteries hidden within the greenery.",
            "Bounces on its hind legs, a joyful display of morning exuberance.",
            "Chirrups in greeting to a passing bird, engaging in morning woodland dialogue.",
            "Leaps from tree to tree, tracing a morning path among the waking giants.",
            "Sits on a sunlit branch, soaking in the morning rays with contentment.",
            "Flicks its tail in a pattern, creating a Morse code message for the morning.",
            "Perches on a mushroom, using it as a morning pedestal for woodland contemplation.",
            "Nudges a pebble with its nose, investigating morning mysteries on the forest floor.",
            "Darts through a patch of ferns, a blur of morning energy in the greenery.",
            "Chatters with a fellow squirrel, sharing morning gossip in the treetop community."
        }
        local speak = {
            "Chittering softly, I greet you, fellow forest dweller.",
            "In the rustling leaves, hear the tales of the ancient oak.",
            "With nimble leaps, I traverse the treetops, a squirrel's domain.",
            "The acorn's journey mirrors our own, a cycle of life and rebirth.",
            "As the leaves fall, so does the wisdom of the woodland whisper.",
            "Through the branches, I spy the secrets hidden in the forest's heart.",
            "In the dappled sunlight, I find solace among the dancing shadows.",
            "The breeze carries whispers of the squirrel council's ancient knowledge.",
            "With a twitch of my tail, I convey the subtle language of the woodland.",
            "In the squirrel parliament, each chitter contributes to the woodland symphony.",
            "With paws as swift as the wind, I navigate the intricate tapestry of branches.",
            "As the acorns drop, so does the gentle rain of nature's bounty.",
            "Behold the acorn, a symbol of promise and the cycle of seasons.",
            "With a leap and a bound, I express the boundless joy of woodland existence.",
            "In the heart of the thicket, the leaves whisper secrets of the forest's past.",
            "The forest floor is a canvas painted with the hues of fallen leaves.",
            "As the moon rises, I become a nocturnal guardian of the treetop realm.",
            "Behold the squirrel acrobat, a dancer in the grand performance of the woods.",
            "Through the maze of branches, I navigate the labyrinth of life's journey.",
            "In the squirrel guild, we master the art of acrobatics and nimble escapades.",
            "With a scurry and a scamper, I leave trails of curiosity in the forest.",
            "As the dewdrops glisten, so do the jewels adorning the leaves.",
            "Behold the squirrel messenger, carrying news from branch to branch.",
            "In the squirrel coliseum, we engage in epic battles of acorn supremacy.",
            "The canopy above is a vast tapestry woven with the threads of sunlight.",
            "With a chitter and a chatter, I communicate the daily tales of the woodland.",
            "As the wind whispers, it shares the ancient stories etched in the bark.",
            "Behold the squirrel philosopher, pondering the mysteries of the acorn.",
            "In the squirrel circus, we perform feats that defy gravity among the leaves.",
            "The bark of the oak tree bears the scars of time, a testament to resilience.",
            "With a nibble and a gnaw, I savor the flavors of nature's pantry.",
            "As the squirrel diplomat, I forge alliances among the creatures of the woods.",
            "Behold the squirrel architect, crafting nests that sway with the breeze.",
            "In the squirrel orchestra, each rustling leaf plays a note in the woodland melody.",
            "The squirrel jamboree is a celebration of acorns, a feast for all to enjoy.",
            "With a tail twitch and a flick, I express the nuances of squirrel emotions.",
            "As the mushrooms bloom, they paint the forest floor with vibrant colors.",
            "Behold the squirrel historian, chronicling the tales of our furry ancestors.",
            "In the squirrel circus, we tightrope walk on branches high above the ground.",
            "The squirrel mosaic is a collage of fur and foliage, a masterpiece of nature.",
            "With a scamper and a hop, I traverse the branches with agile finesse.",
            "As the leaves cradle me in their descent, I become one with the autumn breeze.",
            "Behold the squirrel athlete, conquering the treetops with acrobatic prowess.",
            "In the squirrel parliament, decisions are made with the rustle of leaves.",
            "With a hopscotch leap, I play games among the fallen leaves of the forest floor.",
            "As the owl hoots, the nocturnal world awakens to the symphony of the night.",
            "Behold the squirrel sorcerer, casting spells with the twirl of my bushy tail.",
            "In the squirrel mosaic, we create patterns that mimic the complexity of nature.",
            "With a leap and a glide, I soar through the air with grace and agility.",
            "As the river flows, it mirrors the journey of acorns in the grand cycle of life.",
            "Behold the squirrel philosopher, contemplating the deeper meaning of the nut.",
            "In the squirrel amphitheater, we perform acorn ballets on branches high above.",
            "With a rustle and a shuffle, I gather leaves to fashion a cozy woodland nest.",
            "As the rain falls, it cleanses the forest floor and rejuvenates the earth.",
            "Behold the squirrel diplomat, fostering harmony among the creatures of the woods.",
            "In the squirrel orchestra, the rustling leaves create a symphony of nature's song.",
            "With a twirl and a spin, I navigate the labyrinth of branches with ease.",
            "As the acorns scatter, they become the seeds of future generations of trees.",
            "Behold the squirrel navigator, charting courses through the canopy with precision.",
            "In the squirrel mosaic, we form intricate patterns that mirror the complexity of life.",
            "With a leap and a roll, I play among the foliage in the woodland playground.",
            "As the mushrooms bloom, they add a touch of whimsy to the forest floor.",
            "Behold the squirrel architect, crafting nests that sway with the rhythm of the breeze.",
            "In the squirrel amphitheater, we perform daring acrobatics for an imaginary audience.",
            "With a scamper and a hop, I traverse the branches with playful agility.",
            "As the leaves crunch beneath my paws, I create a symphony of woodland percussion.",
            "Behold the squirrel historian, preserving the tales of our ancestors in the bark.",
            "In the squirrel circus, we tightrope walk on branches high above, defying gravity.",
            "With a twirl and a spin, I navigate the labyrinth of branches with precision.",
            "As the river flows, it mirrors the journey of acorns in the grand cycle of life.",
            "Behold the squirrel philosopher, contemplating the deeper meaning of the nut.",
            "In the squirrel amphitheater, we perform acorn ballets on branches high above.",
            "With a rustle and a shuffle, I gather leaves to fashion a cozy woodland nest.",
            "As the rain falls, it cleanses the forest floor and rejuvenates the earth.",
            "Behold the squirrel diplomat, fostering harmony among the creatures of the woods.",
            "In the squirrel orchestra, the rustling leaves create a symphony of nature's song.",
            "With a twirl and a spin, I navigate the labyrinth of branches with ease.",
            "As the acorns scatter, they become the seeds of future generations of trees.",
            "Behold the squirrel navigator, charting courses through the canopy with precision.",
            "In the squirrel mosaic, we form intricate patterns that mirror the complexity of life.",
            "With a leap and a roll, I play among the foliage in the woodland playground.",
            "As the mushrooms bloom, they add a touch of whimsy to the forest floor.",
            "Behold the squirrel architect, crafting nests that sway with the rhythm of the breeze.",
            "In the squirrel amphitheater, we perform daring acrobatics for an imaginary audience.",
            "With a scamper and a hop, I traverse the branches with playful agility.",
            "As the leaves crunch beneath my paws, I create a symphony of woodland percussion.",
            "Behold the squirrel historian, preserving the tales of our ancestors in the bark.",
            "In the squirrel circus, we tightrope walk on branches high above, defying gravity."
        }
        local speak_win = {
            "In the triumph of the treetops, hear my victorious chitter!",
            "With the rustling leaves as witnesses, I claim victory in the epic battle!",
            "Let the acorns fall like confetti, for I am the champion of the woodland!",
            "As the sun sets, bask in the glory of my triumphant chatter!",
            "Behold, fellow creatures of the forest, the conqueror returns with a bushy tail held high!",
            "In the dance of victory, my tail becomes a banner of triumph!",
            "With every leap and bound, I declare myself the arboreal champion!",
            "Let the branches echo with the resounding cheer of my triumphant chattering!",
            "In the midst of the leaves' applause, I stand as the triumphant ruler of the trees!",
            "With acorns as my scepter, I reign supreme in the kingdom of the canopy!",
            "Witness the squirrel prince, crowned with leaves and victorious in battle!",
            "Let the winds carry the news of my triumph to every nook and cranny of the forest!",
            "In the shadow of the mighty oak, I stand as the undisputed champion!",
            "As the moon rises, let its silver glow illuminate the victorious gleam in my eyes!",
            "With a flurry of fur and a cascade of leaves, I emerge victorious!",
            "Let the squirrel anthem play, for I am the conqueror of the woodland realm!",
            "In the squirrel council, my victory shall be etched in the bark of legend!",
            "With a triumphant leap from tree to tree, I declare myself the arboreal acrobat!",
            "As the stars twinkle, they mirror the gleam of my triumphant gaze!",
            "In the heart of the grove, let the victory dance commence!",
            "Behold the squirrel warrior, victorious in the epic clash of tails and claws!",
            "With a squirrelly battle cry, I claim this triumph in the name of the woodland!",
            "Let the leaves rustle in celebration, for the squirrel champion has emerged!",
            "In the victory parade of branches, I march with the majesty of a woodland monarch!",
            "As the dewdrops sparkle, so does the brilliance of my triumphant conquest!",
            "With a leap of joy, I declare this treetop as the stage of my victory!",
            "Let the forest floor shake with the victory stampede of tiny paws!",
            "In the squirrel coliseum, I am the undefeated champion of tail-fu!",
            "With acorn trophies in paw, I stand as the victorious guardian of the grove!",
            "Behold the whirlwind of victory, as I whirl and twirl in celebration!",
            "In the grand finale of the treetop symphony, my chitters are the melody of triumph!",
            "As the wind carries my victorious chattering, let the woodland creatures cheer!",
            "With a tail salute, I acknowledge the cheers of the defeated leaves below!",
            "In the squirrel jubilee, let the nutty festivities commence!",
            "With a triumphant scurry, I mark my victory in the forest's ledger of legends!",
            "Let the mushrooms burst forth in celebration, for I am the fungi-fied champion!",
            "In the squirrel Olympics, I claim the gold medal in the acrobatics category!",
            "With a bow to the acorn gods, I accept their divine decree of victory!",
            "Behold the champion of the canopy, crowned with leaves and surrounded by glory!",
            "Let the tree bark bear witness to the tale of my epic conquest!",
            "With tail held high, I declare this tree as the monument of my victorious ascent!",
            "In the victory feast of acorns, I shall dine as the undisputed king!",
            "With a twirl of my tail, I paint victory across the canvas of the treetops!",
            "Let the squirrel elders nod in approval, for I am the triumphant apprentice!",
            "In the squirrel sorority, I claim the title of the acorn queen!",
            "With a leap and a bound, I dance in the moonlit celebration of triumph!",
            "Behold the squirrel sorcerer, weaving spells of victory with every chitter!",
            "Let the constellation of acorns be named after the victorious squirrel warrior!",
            "In the squirrel kingdom, I ascend to the throne with leaves as my royal cloak!",
            "With a tail flick and a bound, I declare victory in the squirrelly saga!",
            "Let the squirrel poets compose verses of my triumph in the ancient oak scrolls!",
            "With a leap to the heavens, I touch the treetop zenith of victory!",
            "In the squirrel parliament, my victory speech echoes through the branches!",
            "Behold the acorn jester, entertaining the woodland court with victorious antics!",
            "Let the river of leaves carry the news of my triumph to the farthest corners!",
            "With a toss of my tail, I fling confetti leaves in celebration of victory!",
            "In the squirrel jamboree, I lead the parade with the banner of triumph!",
            "With acorn medals around my neck, I stand as the victorious woodland athlete!",
            "Let the squirrel bards compose ballads of my epic deeds in the forest!",
            "In the squirrel circus, I am the star performer, juggling acorns with finesse!",
            "With a victorious hopscotch among the branches, I leave my mark on the treetops!",
            "Behold the squirrel philosopher, contemplating the profound meaning of victory!",
            "Let the squirrel artisans carve statues in my honor from fallen branches!",
            "With a cascade of leaves, I descend as the triumphant ruler of the descent!",
            "In the squirrel guild, I am the master of acrobatic arts, the victor of leaps!",
            "Behold the squirrel diplomat, forging alliances with every victorious chitter!",
            "With a twirl of my tail, I choreograph the victory ballet of the treetops!",
            "Let the squirrel historians etch my triumph into the ancient tree rings!",
            "In the squirrel circus, I am the tightrope walker, balancing on the thread of victory!",
            "With a leap and a bound, I dance on the stage of triumph in the squirrel amphitheater!",
            "Behold the squirrel navigator, charting the course to victory among the branches!",
            "Let the squirrel heralds announce my triumph with trumpets made of acorns!",
            "With a flutter of leaves, I spread the wings of victory in the arboreal sky!",
            "In the squirrel mosaic, I am the central piece, adorned with the colors of triumph!",
            "Behold the squirrel architect, constructing victory nests in the highest treetops!",
            "With a victorious pose, I become the model for the squirrel artists of the forest!",
            "Let the squirrel philosophers ponder the cosmic significance of my triumph!",
            "In the squirrel orchestra, I conduct the symphony of victory with my tail as the baton!",
            "With a victorious sprint, I leave paw prints on the tapestry of the forest floor!",
            "Behold the squirrel messenger, spreading the news of victory to every corner!",
            "Let the squirrel sages inscribe my name in the chronicles of woodland triumph!",
            "With a triumphant backflip, I somersault through the pages of squirrel history!"
        }
        local speak_dead = {
            "In the quiet embrace of the forest, my spirit finds solace.",
            "As the leaves rustle, know that my memory dances with the wind.",
            "In the shadow of the oak tree, my essence lingers with tender grace.",
            "As the acorns fall, let each one carry a piece of my departed spirit.",
            "In the gentle rain, feel the tears of the woodland mourning my absence.",
            "As the sun sets, let the golden hues be a canvas for my departed soul.",
            "In the hallowed grove, let the echoes of my existence resonate.",
            "As the moon rises, know that my spirit joins the celestial dance.",
            "In the heart of the forest, find the sanctuary where my presence once roamed.",
            "As the brook murmurs, let its melody carry the whispers of my memory.",
            "In the rustling leaves, hear the soft murmur of my final farewell.",
            "As the dew settles, feel the cool touch of my essence in the morning air.",
            "In the stillness of the night, let the stars be witnesses to my silent departure.",
            "As the squirrel chatters, sense the echo of my voice in the woodland symphony.",
            "In the whispering wind, catch the fragments of my parting words.",
            "As the seasons change, let each transformation be a testament to my eternal cycle.",
            "In the mossy hollow, find the sanctuary where my spirit once rested.",
            "As the shadows dance, see the silhouette of my departed form.",
            "In the ancient tree, find the refuge where my memory nests.",
            "As the petals fall, let each one be a petal of remembrance for me.",
            "In the heart of the grove, let the tree roots cradle the essence of my being.",
            "As the morning dew glistens, let it be a reflection of the tears shed for my passing.",
            "In the warmth of the sunlight, feel the gentle caress of my eternal presence.",
            "As the wind whispers through branches, hear the murmur of my farewell song.",
            "In the heartwood of the oak, find the engraving of my departed spirit.",
            "As the ferns unfurl, let each frond carry the essence of my memory.",
            "In the ancient glade, find the sacred space where my spirit takes its rest.",
            "As the squirrel gathers acorns, let each one be a token of my existence.",
            "In the dappled sunlight, feel the warmth of my memory on your fur.",
            "As the breeze rustles through leaves, sense the touch of my ethereal presence.",
            "In the quiet clearing, let the petals of remembrance fall softly.",
            "As the owl hoots, let it be a lament for my departed spirit.",
            "In the heart of the meadow, find the spot where my essence once played.",
            "As the raindrop falls, let it carry the weight of my remembered footsteps.",
            "In the moonlit glen, let the silver beams weave a tapestry of my essence.",
            "As the mushrooms bloom, let each cap carry a memory of my existence.",
            "In the timeless grove, let the ancient trees stand as witnesses to my passing.",
            "As the shadows lengthen, feel the embrace of my lingering spirit.",
            "In the cool shade, find the refuge where my soul once sought respite.",
            "As the stream flows, let its current carry the whispers of my name.",
            "In the heart of the thicket, let the flowers bloom as a tribute to my memory.",
            "As the wind sighs, hear the echo of my last breath in the rustling leaves.",
            "In the moonlit pond, let the ripples carry the reflection of my departed form.",
            "As the crickets chirp, let their song be a serenade for my eternal rest.",
            "In the hollow log, find the chamber where my spirit once sought shelter.",
            "As the stars twinkle, let them be the eyes that watch over my journey beyond.",
            "In the ancient redwood, find the sanctuary where my spirit once soared.",
            "As the fog rolls in, let it be the veil that shrouds my ethereal form.",
            "In the heart of the grove, let the fireflies dance as a tribute to my spirit.",
            "As the leaves carpet the forest floor, let each one carry a piece of my memory.",
            "In the twilight haze, let the fireflies weave constellations of my existence.",
            "As the rabbit hops by, let it carry the message of my peaceful transition.",
            "In the sacred circle, let the stones mark the space where my spirit once lingered.",
            "As the breeze carries scent, let it bring back the fragrance of my being.",
            "In the heart of the labyrinth, find the path where my spirit once tread.",
            "As the pinecones drop, let each one be a token of remembrance for me.",
            "In the moonlit ferns, let the silver strands be the threads of my departed essence.",
            "As the violets bloom, let each petal carry the color of my remembered presence.",
            "In the heart of the thicket, let the dewdrops be diamonds in the crown of my memory.",
            "As the wind murmurs secrets, let it whisper tales of my earthly journey.",
            "In the shadow of the willow, find the bough where my spirit once swung.",
            "As the ant crawls, let it carry the message of my peaceful slumber.",
            "In the moonlit moss, let the green embrace symbolize the everlasting life of my memory.",
            "As the river flows, let its current carry the reflections of my remembered image.",
            "In the heart of the glade, let the mushrooms stand as pillars to honor my spirit.",
            "As the spider weaves its web, let it be a tapestry woven with the threads of my existence.",
            "In the twilight mist, let the whispers of my name linger in the air.",
            "As the willow branches sway, let them be the arms that cradle my spirit.",
            "In the heart of the labyrinth, let the stones mark the path where my spirit once trod.",
            "As the acorns drop, let each one be a token of remembrance for me.",
            "In the moonlit ferns, let the silver strands be the threads of my departed essence.",
            "As the violets bloom, let each petal carry the color of my remembered presence.",
            "In the heart of the thicket, let the dewdrops be diamonds in the crown of my memory.",
            "As the wind murmurs secrets, let it whisper tales of my earthly journey.",
            "In the shadow of the willow, find the bough where my spirit once swung.",
            "As the ant crawls, let it carry the message of my peaceful slumber.",
            "In the moonlit moss, let the green embrace symbolize the everlasting life of my memory.",
            "As the river flows, let its current carry the reflections of my remembered image.",
            "In the heart of the glade, let the mushrooms stand as pillars to honor my spirit.",
            "As the spider weaves its web, let it be a tapestry woven with the threads of my existence.",
            "In the twilight mist, let the whispers of my name linger in the air.",
            "As the willow branches sway, let them be the arms that cradle my spirit.",
            "In the heart of the labyrinth, let the stones mark the path where my spirit once trod.",
            "As the acorns drop, let each one be a token of remembrance for me."
        }
        if (type:lower() == "speak") then
            collection = speak
        elseif (type:lower() == "emote") then
            collection = emote
        elseif (type:lower() == "speak_win") then
            collection = speak_win
        elseif (type:lower() == "emote_summon") then
            collection = emote_summon
        elseif (type:lower() == "speak_dead") then
            collection = speak_dead
        end
        local comment = "Has nothing interesting to say"
        if (collection ~= nil and OracleHUD_TableGetLength(collection) > 0) then
            comment = collection[math.random(1, OracleHUD_TableGetLength(collection))]
        end
        return comment
    end
end
