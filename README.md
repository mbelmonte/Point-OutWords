Autista
=======

iPad software for communicative skills development in non-verbal or minimally verbal persons with autism

Autista is designed to help autistic children with speech difficulties develop manual motor and oral motor skills, building an ability to communicate by pointing or speaking.  Autista bootstraps new skills by beginning from activities at which autistic children excel and that they enjoy -- assembling puzzles, for instance -- and harnessing this motivation to approach new challenges.

Children begin by learning to point and to drag puzzle pieces in Point Mode.  In addition to developing these basic motor skills, they become accustomed to the idea that objects consist of sequences of parts.

With Type Mode, children progress from pointing at puzzle pieces in sequence to pointing at letters of the alphabet in sequence, making the jump from communicating in pictures to communicating in words.  Each letter pressed on the keyboard causes a puzzle piece to spring into place.

In Speak Mode, children practice pronouncing syllables in sequence. Each syllable pronounced causes a puzzle piece to spring into place.

Code Structure:
The main body of code for the app is in /Austista/. 

TestFlight - External Testing SDK

External - Empty

/Helper Classes/ - Libraries used to handling JSON, and Payment Related functions

/Models/
- Event Logger class
  - Log Functions
  - Change Mode - Suggest Mode Function
- Global Preferences - Settings
- Other Files related to Core Data

/Audio/ - External Audio Related Classes

/Classes/
- RootViewController - Entering view for the app
- FirstLaunchViewController - Show introduction when first launch
- SceneSelectorViewController - Allow user to choose a scene
- SceneViewController - Allow user to choose a puzzle from the scene, then lead him to the puzzle in a certain mode
- SayPuzzleViewController - Puzzle in say mode
- TouchPuzzleViewController - Puzzle in touch mode
- TypePuzzleViewController - Puzzle in type mode
  - TypeBanner - The top banner of word and letters in type mode
- PuzzlePieceView - Each puzzle piece
- AdminViewController - Manage app settings
  - PuzzleStateView - Show status of puzzles in a scene

/Images/ and /Scenes/ - Graphical resources for the app

/Prompts/, /Sounds/, /Syllables/ and /Words/ - Sound resources for the app


We include a Apple-style documentation in /AustistaDocs/html/. Detailed description of the code structure, classes, properties, and methods are presented.

For illustration of how different parts of the app works, please refer to the flow chart in /AutistaDocs/flowchart.png 
