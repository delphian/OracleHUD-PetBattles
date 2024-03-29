if (ORACLEHUD_PB_DB_UPDATE == nil) then
    ORACLEHUD_PB_DB_UPDATE = {}
end
ORACLEHUD_PB_DB_UPDATE.s419 = function(db) 
    db.content.petComments.s419 = function(db, type)
        local comment = nil
        local collection = nil
        if (type == nil) then
            type = "speak"
        end
        local emote = {
            "hops around excitedly",
            "ribbits loudly",
            "snaps at a passing insect",
            "camouflages itself in the tall grass",
            "leaps from lily pad to lily pad",
            "nudges a nearby stone with its nose",
            "blinks its large eyes curiously",
            "stretches its hind legs",
            "watches the clouds drifting by",
            "snags a small fly with its tongue",
            "burrows into the mud for a moment",
            "inflates its throat sac in a display",
            "sways gently with the breeze",
            "balances on a narrow branch",
            "croaks softly in the moonlight",
            "darts its tongue out in anticipation",
            "tries to catch its own reflection",
            "dives into a small puddle",
            "licks its eyes with a quick flick",
            "sits still, blending into the environment",
            "shakes off water after a swim",
            "nabs a passing mosquito",
            "closes its eyes in contentment",
            "spreads its webbed feet wide",
            "swims in lazy circles",
            "listens intently to distant sounds",
            "perches on a rock, surveying its domain",
            "hisses at a larger creature",
            "tries to climb a vertical surface",
            "croaks rhythmically like a drum",
            "basks in a patch of warm sunlight",
            "snuggles into a bed of leaves",
            "watches its own reflection in a pond",
            "burps after a particularly big meal",
            "plays leapfrog with a companion",
            "burrows into a pile of fallen leaves",
            "navigates a maze of tall grass",
            "climbs onto a floating log",
            "sniffs at a passing insect",
            "basks in the warmth of a campfire",
            "imitates the calls of other creatures",
            "balances on a lilypad's edge",
            "bounces playfully on all fours",
            "blinks slowly, enjoying the sun",
            "sways with the rhythm of falling rain",
            "wiggles its toes in the mud",
            "catches a falling leaf with its tongue",
            "burrows into the sand for a rest",
            "snuggles against a larger creature",
            "stares at the stars in fascination",
            "tries to hop on two legs briefly",
            "grins (or at least, it looks like a grin)",
            "watches the ripples in a pond",
            "ducks under a leaf for cover",
            "sits still, waiting for a passing bug",
            "rubs its belly on a smooth surface",
            "licks its lips after a tasty meal",
            "dances a small jig on its hind legs",
            "snaps at a dangling vine",
            "croons a melodious froggy tune",
            "does a somersault in the air",
            "hides in a hollow log for safety",
            "gulps down a large insect whole",
            "puffs up to appear larger",
            "surveys its surroundings with caution",
            "creates a small bubble nest in water",
            "sways with the movement of tall grass",
            "gazes at the reflection of the moon",
            "nabs a butterfly with a quick snap",
            "snuggles into the warmth of a rock",
            "tries to catch its own shadow",
            "gobbles up a tasty earthworm",
            "stands on its hind legs briefly",
            "snaps at a passing dragonfly",
            "rests on a floating lily pad",
            "stomps its feet in a froggy dance",
            "grooms its skin with its front legs",
            "watches the glow of fireflies",
            "imitates the calls of nearby frogs",
            "dives into a pond with a splash",
            "shivers to shake off excess water",
            "snuggles into a bed of moss",
            "pounces on a unsuspecting bug",
            "basks in the warmth of a rock",
            "swirls its tongue like a propeller",
            "does a little hopscotch dance",
            "peeks out from behind a leaf",
            "snaps at passing raindrops",
            "gazes at the reflection in water",
            "rubs its belly against a smooth stone",
            "bounces on a mossy log",
            "licks its lips after a tasty snack",
            "catches a falling blossom with its tongue",
            "snuggles into a cozy nook",
            "nudges a nearby pebble",
            "shuffles its feet in a dance",
            "imitates the sound of rainfall",
            "snaps at a pesky mosquito"
        }
        local emote_summon = {
            "opens its eyes and blinks in the morning light",
            "stretches its little froggy limbs",
            "yawns wide, displaying its tiny throat sac",
            "snuggles into a cozy spot, reluctant to leave its bed",
            "hops out of its sleeping nook with enthusiasm",
            "wiggles its toes in the warmth of the morning sun",
            "croaks a sleepy tune to the dawn chorus",
            "rubs its eyes with its front legs",
            "licks its lips, anticipating breakfast",
            "ponders the new day with a thoughtful look",
            "pokes its head out from under a leafy blanket",
            "shakes off the last remnants of sleep",
            "sniffs the morning air with curiosity",
            "stares at the sky, contemplating the day ahead",
            "grooms its skin with gentle strokes",
            "basks in the first rays of sunlight",
            "peeks out from its hiding spot with a curious gaze",
            "puffs up its cheeks and exhales a little sigh",
            "rolls over, reluctant to leave its comfortable spot",
            "hops in a circle, energized by the morning",
            "snaps at a passing insect for an early snack",
            "watches the dew glisten on the leaves",
            "flips its hind legs in the air in a joyful flip",
            "savors the warmth of a morning breeze",
            "nudges a fellow frog with a friendly greeting",
            "ponders the mysteries of the pond in quiet contemplation",
            "tries to catch a falling leaf for morning entertainment",
            "dives into a puddle to freshen up",
            "sways to an imaginary melody in the morning air",
            "pokes its nose out and sniffs the morning dew",
            "balances on a rock, practicing morning yoga",
            "wiggles its webbed toes in the cool water",
            "pounces on a passing bug with morning hunger",
            "hops from one lily pad to another in a morning exploration",
            "peers into the water to admire its reflection",
            "gulps down a morning insect with a swift snap",
            "basks in the glow of the sunrise",
            "blinks away sleep and surveys its surroundings",
            "stirs the water with its webbed feet in a gentle morning splash",
            "jumps onto a log to get a better view of the sunrise",
            "leans into the warmth of a sunlit rock",
            "practices its morning croak, tuning its vocal sac",
            "snuggles with a froggy friend for a cozy wake-up",
            "pads its little froggy bed to make it just right",
            "swims lazy circles in the morning pond",
            "hops onto a leaf and rides it like a morning boat",
            "scratches an itch behind its ear with a hind leg",
            "chuckles softly at the morning's secrets",
            "watches the morning mist rise from the water",
            "snacks on morning dew droplets",
            "nudges a pebble into the water, creating ripples",
            "perches on a rock and watches the world awaken",
            "gazes at the morning sky with wonder",
            "practices tiny jumps to limber up its legs",
            "puffs up its throat sac to impress the morning",
            "catches a glimpse of a passing dragonfly",
            "ponders the meaning of life with a philosophical croak",
            "snuggles into a bed of soft grass",
            "bounces from one leaf to another in morning play",
            "dips its feet into the cool water and sighs",
            "pokes its head out and greets the morning with a cheerful ribbit",
            "prances around with morning energy",
            "snags a morning snack with a quick snap of its tongue",
            "stares at the morning sky as if reading a froggy story",
            "wades through the morning dew with delicate steps",
            "hops onto a rock and enjoys the morning view",
            "chirps a morning melody in harmony with nature",
            "snuggles into a sun-warmed nook for a lazy start",
            "blows a tiny bubble in the morning pond",
            "gazes at its reflection and practices froggy poses",
            "sniffs the morning breeze for interesting scents",
            "pounces on a morning shadow for playful fun",
            "balances on a lily pad and practices morning meditation",
            "watches the morning insects with keen interest",
            "pokes its tongue out for a morning stretch",
            "gulps down a morning mosquito for a quick meal",
            "snuggles into the morning warmth of a sunlit stone",
            "dives into a pile of leaves and rustles them about",
            "swirls its tongue in a morning water dance",
            "hops onto a passing breeze and rides it like a tiny surfer",
            "wiggles its webbed toes in the morning grass",
            "basks in the first light, absorbing the day's energy",
            "practices tiny hops in a morning leapfrog game",
            "snaps at a morning snack with precision",
            "ponders the morning with wide, thoughtful eyes"
        }
        local speak = {
            "Ribbit!",
            "Croak croak!",
            "Hop to it!",
            "Bug buffet anyone?",
            "Feeling jumpy today!",
            "Watch me do a flip!",
            "Froggy high-five!",
            "In the pond, life is grand!",
            "Got any flies?",
            "Ripples in the water, thoughts on my mind.",
            "It's not easy being green.",
            "What's hopping, my friend?",
            "Lily pads make the best seats.",
            "Life's a leap of faith!",
            "Every day is a hopping good day!",
            "Just keep leaping, just keep leaping...",
            "Singing in the rain, ribbiting in the pond.",
            "Pond reflections are the best reflections.",
            "Croak softly and carry a big jump!",
            "In the pond, we trust.",
            "Fly snacks are the best snacks.",
            "Froggy fashion: webbed toes are in!",
            "A good day starts with a croak.",
            "Frogs rule, flies drool!",
            "Amphibians unite!",
            "Toadally awesome!",
            "Hoppy thoughts, hoppy life.",
            "Don't be a tadpole forever!",
            "Sunbathing is my favorite sport.",
            "Just froggin' around!",
            "When life gives you lily pads, make a cozy bed.",
            "Frogs: the original acrobats!",
            "Froggy wisdom: jump first, ask questions later.",
            "Catching dreams, one leap at a time.",
            "The early frog catches the bug.",
            "Croak softly and carry a big jump!",
            "Leap before you look!",
            "Pond life is the best life.",
            "Feeling a bit green today.",
            "Flies for thought.",
            "Hoppy trails to you!",
            "A frog in the hand is worth two in the pond.",
            "Frog legs are for jumping, not eating!",
            "Ribbiting is my favorite language.",
            "Leaping through life with style!",
            "Rainy days are perfect for a good croak.",
            "Frogs: the original eco-friendly commuters.",
            "Cattails make the best microphones!",
            "Hopscotch champion reporting in!",
            "Lily pads are nature's magic carpets.",
            "Croak on, my friend!",
            "Life's a lily pad, jump on it!",
            "Warts and all, I'm fabulous!",
            "Catch you on the flip side!",
            "What's jumpin'?",
            "Frog kisses bring good luck!",
            "In the pond, we ponder.",
            "Flies, the other green meat.",
            "A leap a day keeps the blues away!",
            "Frogs: the real environmentalists.",
            "Pond reflections, deep thoughts.",
            "Froggy fact: lily pads are nature's sofas.",
            "Raindrops are like nature's applause.",
            "A pond without frogs is like a day without ribbits.",
            "The best things in life are green.",
            "Jumping is my cardio!",
            "Hoppy endings are the best endings.",
            "Croak softly and carry a big jump!",
            "Froggy dreams are the sweetest.",
            "Lily pads are stepping stones to happiness.",
            "In the pond, no one judges your croak.",
            "Flies are like potato chips for frogs.",
            "Ribbits are my love language.",
            "Leap into the unknown, it's more fun!",
            "Every puddle is a potential pond.",
            "Pond life: the ultimate chill zone.",
            "Froggy friends make the best company.",
            "Jump for joy!",
            "Flies are the icing on life's cake.",
            "Leapin' lizards, I mean frogs!",
            "Life's a pond, jump in!",
            "Catching sunshine, one hop at a time.",
            "Froggy tales and lily pad trails.",
            "Ribbits: the universal language of happiness.",
            "Hop, skip, and a jump!",
            "In the pond, we trust.",
            "Lily pads: the froggy version of a bean bag chair.",
            "Rainy days are just froggy spa days.",
            "Feelin' froggy today!",
            "Leapin' into action!",
            "Froggy friends are forever friends.",
            "Pond life lessons: jump often, nap well.",
            "Croaking at the moon, it's a froggy tradition."
        }
        local speak_win = {
            "Ribbit-tastic victory!",
            "Hoppy days, I'm the champion!",
            "Croak of triumph!",
            "Frogs 1, Enemies 0!",
            "Leapin' lily pads, that was epic!",
            "Victory dance time!",
            "In the pond, we reign supreme!",
            "Croakalicious win!",
            "Froggy power for the win!",
            "Hop-tastic triumph!",
            "Ribbits of glory!",
            "Flies and foes, conquered!",
            "Amphibious excellence achieved!",
            "That battle was a leap in the right direction!",
            "Croakity croak, victory spoke!",
            "In the pond, we trust, and we triumph!",
            "Hoppin' into the winner's circle!",
            "Jumping for joy, I'm the victor!",
            "Froggy fantastic win!",
            "Ribbiting success!",
            "Hop on my level, defeated foes!",
            "Victory, the sweetest sound!",
            "Frogs: 1, Adversaries: 0!",
            "I'm the froggy boss now!",
            "Leapin' into the hall of fame!",
            "That battle was ribbeting!",
            "Croakalicious conquest!",
            "Frogs unite, victory in sight!",
            "Hopping to the top!",
            "Ribbiting success story!",
            "In the pond, we prevail!",
            "Hop-tacular win!",
            "Croak of champions!",
            "Frogs rule, foes drool!",
            "Leapin' lily pads, what a win!",
            "Victory hops for everyone!",
            "Ribbiting good time for triumph!",
            "Hop on, hop strong, hop victorious!",
            "Frogs: 1, Rivals: 0!",
            "In the pond, victory resonates!",
            "Jumping into the history books!",
            "Ribbiting conclusion to the battle!",
            "Hoppy days, I'm the winner!",
            "Croaktastic success!",
            "Froggy fantastic finish!",
            "Victory, the ultimate croak of joy!",
            "Leapin' ahead of the competition!",
            "Ribbits of triumph echoed through the battlefield!",
            "Hop-tastic achievement unlocked!",
            "Froggy forces, unstoppable!",
            "In the pond, victory echoes!",
            "Croakalicious celebration!",
            "Hoppin' high on success!",
            "Ribbiting good win!",
            "Hoppy victory vibes!",
            "Frogs, undefeated champions!",
            "Victory is the best croak!",
            "Leapin' with pride!",
            "Ribbits of glory, heard from afar!",
            "In the pond, we conquer!",
            "Croakalicious conquest achieved!",
            "Froggy fantastic finish!",
            "Victory, the sweetest croak!",
            "Hop-tacular success story!",
            "Ribbits of joy and triumph!",
            "Hoppin' into the winner's circle!",
            "Frogs: 1, Foes: 0!",
            "Victory, the amphibious anthem!",
            "Leapin' lily pads, what a win!",
            "Ribbiting conclusion to the battle!",
            "Hop on, hop strong, hop victorious!",
            "In the pond, victory resonates!",
            "Froggy forces, unstoppable!",
            "Croakalicious celebration!",
            "Hoppin' high on success!",
            "Ribbiting good win!",
            "Hoppy victory vibes!",
            "Frogs, undefeated champions!",
            "Victory is the best croak!",
            "Leapin' with pride!",
            "Ribbits of glory, heard from afar!",
            "In the pond, we conquer!",
            "Croakalicious conquest achieved!",
            "Froggy fantastic finish!",
            "Victory, the sweetest croak!",
            "Hop-tacular success story!",
            "Ribbits of joy and triumph!",
            "Hoppin' into the winner's circle!",
            "Frogs: 1, Foes: 0!",
            "Victory, the amphibious anthem!",
            "Leapin' lily pads, what a win!",
            "Ribbiting conclusion to the battle!",
            "Hop on, hop strong, hop victorious!",
            "In the pond, victory resonates!",
            "Froggy forces, unstoppable!",
            "Croakalicious celebration!",
            "Hoppin' high on success!",
            "Ribbiting good win!",
            "Hoppy victory vibes!",
            "Frogs, undefeated champions!",
            "Victory is the best croak!",
            "Leapin' with pride!",
            "Ribbits of glory, heard from afar!",
            "In the pond, we conquer!",
            "Croakalicious conquest achieved!"            
        }
        local speak_dead = {
            "In the pond of memories, I'll forever swim.",
            "The lily pads of life were sweet, but the journey must end.",
            "With each leap, I left a ripple of joy. Remember me fondly.",
            "Frogs may croak, but my spirit will always ribbit.",
            "Among the cattails of life, my presence will linger.",
            "In the quiet of the night, listen for my gentle croak.",
            "As the dew settles, so does my memory in the pond of time.",
            "Even in silence, my hoppy heart echoes in the pond of life.",
            "Remember me with a leap, not a tear.",
            "In the tadpole of time, my essence remains.",
            "The pond of life was richer with each ripple I created.",
            "Like the evening mist, my spirit dances on the water.",
            "In the hopscotch of memories, find comfort.",
            "As fireflies light the night, so does my spirit glow.",
            "Frogs may be small, but our impact is immeasurable.",
            "In the symphony of nature, listen for my croak.",
            "Life is a pond, and I was a humble frog in its depths.",
            "Among the reeds of reminiscence, I rest peacefully.",
            "May the lilypads of love support you in my absence.",
            "Leap from sorrow to joy, for my spirit knows no bounds.",
            "The tadpoles of time swim onward, carrying my essence.",
            "Among the water lilies, find solace in memories.",
            "The pond of life reflects the beauty of our shared moments.",
            "In the pond of existence, my ripples linger as love.",
            "Like a dragonfly in flight, my spirit soars beyond the horizon.",
            "As the stars twinkle, know that I too shimmer in memory.",
            "In the marsh of emotions, my spirit wades with you.",
            "In the hop of hope, find comfort and carry on.",
            "May the ripple of my existence inspire leaps of joy.",
            "Like a raindrop in the pond, my impact is felt far and wide.",
            "As the lotus blooms, so does the memory of my life.",
            "Among the lilypads of love, my spirit finds eternal rest.",
            "In the croak of the heart, my essence resonates.",
            "May the pond of life be ever teeming with joyous leaps.",
            "As the sun sets, my spirit follows the path of twilight.",
            "In the harmony of nature, my song remains.",
            "In the tadpole of time, cherish the moments we shared.",
            "May the water lilies of love forever grace your pond of life.",
            "As fireflies dance, so does the memory of my joyous leaps.",
            "In the pond of memories, may you find tranquility.",
            "Among the lily pads, my spirit takes refuge.",
            "In the frog chorus of life, listen for my silent croak.",
            "May the reflections of our moments together ripple through time.",
            "Like a rain shower in spring, my presence brings growth.",
            "In the leap of faith, find strength to carry on.",
            "As the moon reflects on the water, so do I reflect in your heart.",
            "In the quiet of the night, my spirit leaps among the stars.",
            "May the lily pads of love cradle your heart in my absence.",
            "As the dragonfly hovers, so does the memory of my presence.",
            "In the leap of love, find the strength to embrace tomorrow.",
            "Among the water lilies, my spirit blooms eternally.",
            "May the ripples of my existence bring waves of comfort.",
            "In the pond of memories, I rest among the water lilies.",
            "Like the evening mist, my spirit envelopes you with love.",
            "In the croak of the heart, my essence echoes in your soul.",
            "May the lilypads of love guide you through the pond of life.",
            "As the stars twinkle, know that I too shine in memory.",
            "In the marsh of emotions, my spirit wades with you.",
            "In the hop of hope, find solace and carry on.",
            "May the ripple of my existence inspire leaps of joy.",
            "Like a dragonfly in flight, my spirit soars beyond the horizon.",
            "As the stars twinkle, know that I too shimmer in memory.",
            "In the marsh of emotions, my spirit wades with you.",
            "In the hop of hope, find comfort and carry on.",
            "May the ripple of my existence inspire leaps of joy.",
            "Like a dragonfly in flight, my spirit soars beyond the horizon.",
            "As the stars twinkle, know that I too shimmer in memory.",
            "In the marsh of emotions, my spirit wades with you.",
            "In the hop of hope, find comfort and carry on.",
            "May the ripple of my existence inspire leaps of joy.",
            "Like a dragonfly in flight, my spirit soars beyond the horizon.",
            "As the stars twinkle, know that I too shimmer in memory.",
            "In the marsh of emotions, my spirit wades with you.",
            "In the hop of hope, find comfort and carry on.",
            "May the ripple of my existence inspire leaps of joy.",
            "Like a dragonfly in flight, my spirit soars beyond the horizon.",
            "As the stars twinkle, know that I too shimmer in memory.",
            "In the marsh of emotions, my spirit wades with you.",
            "In the hop of hope, find comfort and carry on.",
            "May the ripple of my existence inspire leaps of joy.",
            "Like a dragonfly in flight, my spirit soars beyond the horizon.",
            "As the stars twinkle, know that I too shimmer in memory.",
            "In the marsh of emotions, my spirit wades with you.",
            "In the hop of hope, find comfort and carry on.",
            "May the ripple of my existence inspire leaps of joy.",
            "Like a dragonfly in flight, my spirit soars beyond the horizon.",
            "As the stars twinkle, know that I too shimmer in memory.",
            "In the marsh of emotions, my spirit wades with you.",
            "In the hop of hope, find comfort and carry on.",
            "May the ripple of my existence inspire leaps of joy.",
            "Like a dragonfly in flight, my spirit soars beyond the horizon.",
            "As the stars twinkle, know that I too shimmer in memory.",
            "In the marsh of emotions, my spirit wades with you.",
            "In the hop of hope, find comfort and carry on.",
            "May the ripple of my existence inspire leaps of joy.",
            "Like a dragonfly in flight, my spirit soars beyond the horizon.",
            "As the stars twinkle, know that I too shimmer in memory.",
            "In the marsh of emotions, my spirit wades with you.",
            "In the hop of hope, find comfort and carry on.",
            "May the ripple of my existence inspire leaps of joy.",
            "Like a dragonfly in flight, my spirit soars beyond the horizon.",
            "As the stars twinkle, know that I too shimmer in memory.",
            "In the marsh of emotions, my spirit wades with you.",
            "In the hop of hope, find comfort and carry on.",
            "May the ripple of my existence inspire leaps of joy.",
            "Like a dragonfly in flight, my spirit soars beyond the horizon.",
            "As the stars twinkle, know that I too shimmer in memory.",
            "In the marsh of emotions, my spirit wades with you.",
            "In the hop of hope, find comfort and carry on.",
            "May the ripple of my existence inspire leaps of joy.",
            "Like a dragonfly in flight, my spirit soars beyond the horizon.",
            "As the stars twinkle, know that I too shimmer in memory.",
            "In the marsh of emotions, my spirit wades with you.",
            "In the hop of hope, find comfort and carry on.",
            "May the ripple of my existence inspire leaps of joy.",
            "Like a dragonfly in flight, my spirit soars beyond the horizon.",
            "As the stars twinkle, know that I too shimmer in memory.",
            "In the marsh of emotions, my spirit wades with you.",
            "In the hop of hope, find comfort and carry on.",
            "May the ripple of my existence inspire leaps of joy.",
            "Like a dragonfly in flight, my spirit soars beyond the horizon.",
            "As the stars twinkle, know that I too shimmer in memory.",
            "In the marsh of emotions, my spirit wades with you.",
            "In the hop of hope, find comfort and carry on.",
            "May the ripple of my existence inspire leaps of joy.",
            "Like a dragonfly in flight, my spirit soars beyond the horizon.",
            "As the stars twinkle, know that I too shimmer in memory.",
            "In the marsh of emotions, my spirit wades with you.",
            "In the hop of hope, find comfort and carry on.",
            "May the ripple of my existence inspire leaps of joy.",
            "Like a dragonfly in flight, my spirit soars beyond the horizon.",
            "As the stars twinkle, know that I too shimmer in memory.",
            "In the marsh of emotions, my spirit wades with you.",
            "In the hop of hope, find comfort and carry on.",
            "May the ripple of my existence inspire leaps of joy.",
            "Like a dragonfly in flight, my spirit soars beyond the horizon.",
            "As the stars twinkle, know that I too shimmer in memory.",
            "In the marsh of emotions, my spirit wades with you.",
            "In the hop of hope, find comfort and carry on.",
            "May the ripple of my existence inspire leaps of joy."
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
