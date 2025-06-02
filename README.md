Bacterium Vanquisher is a SwiftUI copy of the Virus Buster minigame from the Brain Age series on the Nintendo DS. 



https://github.com/user-attachments/assets/6af4526d-be37-4131-97b3-8b5ed8bd3ec5



## context
The first game console my family ever purchased was a Nintendo DSi XL. It came pre-loaded with two Brain Age Express games (Math and Arts & Letters). Some of us regularly did the training as intended, but the real highlight was Virus Buster, the last game mode to be unlocked. It is a relatively recent entry in Nintendo's line of Dr. Mario-like games, attention for which seems to have fallen by the wayside.

Recently our old DSi XL resurfaced, and I was surprised at how fun Virus Buster still is to play. I looked for modern versions on the web and for mobile, but found the options lacking. Most are focused on recreating Dr. Mario, and lack the feature that made Virus Buster so compelling to me: the ability to move any falling pills, not just the one most recently dropped. Our DSi is old, and worried I would lose the only version we (my family) liked, I sought to recreate it. Unfortunately, I am not a game dev. The result is a bit hacky (I don't think SwiftUI was meant to be used for games), and not all the way there yet, but I think it's a decent start.

The name is just a silly play on the initialism of Virus Buster being VB. Swapping this around gives BV, but we can retain the essence of the name with "Bacterium Vanquisher". I also think it's funny that it sounds more intense but is actually a lot simpler (for now).

## current state
This app has okay feature parity with easy mode from the inspiration.
- Pills enter the game one at a time, after the last pill is placed
- Any falling pill can moved and rotated
- Pills can "jump" past obstacles horizontally (viruses or other pills), but not pass through them to rows below
- Rotation is smart, and will move the pill over by a space if there would not be space for a normal rotation
- Aligning more than 4 pieces of the same colour is supported, including simultaneous alignment horizontally and vertically
- The next piece to enter is shown in the top left corner

Things I chose not to include for now:
- In Virus Buster, pills fall faster after their initial placement. I didn't add this yet since I still want to experiment with tick rate and the base falling speed, but I expect it'd be pretty easy.
- A score system. I wanted to match the scoring system from Virus Buster, but it is surprisingly complicated. I hope to study it properly soon to try and figure it out.
- Level generation in Virus Buster will never result in having 3 viruses of the same colour in a row. In this app, it's just random. Even 6 in a row is possible (though rare), but popping them all at once doesn't always work correctly. This is just me being lazy, I'll probably fix it soon.
- Losing a round isn't very clearly defined/consistent with the original, but it's close enough for now since I expect there to be some changes coming that will impact this.
- There also aren't any pause, level success, or restart buttons. I'm sure they'd be fairly straightforward to implement, but again, I didn't see the point when the games not in a very fun state anyways.
- Also, there is a bug right now that can allow for pills to be pilled through placed pieces vertically, into the rows below. It's a bit difficult to do and doesn't come up with normal play (and also kind of adds another dimension to play with, which is cool), but I should try and fix it. I expect this being fixed will be a natural consequence of other changes I want to make, but I also wouldn't mind it sticking around. 

Regarding the code, I am happy it seems to be stable and functional, but with this being the most complex game I've made thus far, I made some pretty poor decisions out of the gate. I learned a lot though, and have some clear ideas for improvement with a large refactor. Most significantly, I tried to do something like a MVVM architecture, but the separation of concerns didn't end up as clean as I'd like. Also, modifying state is done a bit haphazardly, and I think the game's parameters are too rigid.

## what's next
The graphics obviously aren't great, but that isn't of much concern to me. If I did ever want to release this though (highly unlikely), I would definitely need to at least figure out some animations for popping pieces, and sprites to better differentiate the targets and the player's pieces.

For now, I think it would be a good idea to rewrite most of the app, mostly for code quality. But there are a few things I'd also like to add:
- as already mentioned, better level generation and a proper game loop (pausing, game over/winning, restart)
- better pill placement: it can be a bit awkward to actually place the pills because of how its setup right now. There are a few ways this could be improved, some simple and some difficult, but I think it's probably a solved problem in the falling block puzzle game genre, and I should just do some research.
- interactions between pills isn't exactly as it is in Virus Buster. For example, there isn't much tolerance for pills to touch before they are placed, so this version is in a bit of an Uncanny Valley position right now. Ironing out these details would probably be difficult, but also extremely important to actually make this app fun.

Long term, the last missing features to add would be a score system and progression through levels (more pills falling in each wave, increasing falling speed, more viruses in the stage etc). Beyond that, I have some ideas to take the game beyond its origins to make it compelling in the modern mobile game scene (basically add some roguelike elements), but it's doubtful I ever get that far. Really, I just want to get this to a place where my mom can have fun playing one of her favourite games on the go (though I'm sure it won't be as good as the original if it isn't played with a stylus).
