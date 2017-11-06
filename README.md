insta23

Instagram ios app (ObjC)

This app has been written in Objective C.

In the interest of time, I have implemented networking-only solution. The best solution would be a combination of Networking and Core Data. It would be great to utilize the phone's sqlite3 database and have entities for Stream posts.

Since this is a networking-only solution, all data is fetched from the API on demand.

The only external library that was used was AFNetworking. It was obtained via CocoaPods, so I am including both project file, workspace file, and Pods containing AFNetworking and any dependencies.

The flow is simple. When user opens the app, he is presented with a simple screen (provided by LoginViewController) that contains the Login button. Clicking on the button will open the instagram's login page via the web view. This is the implicit login method that was advised in the instructions. Upon entering login credentials (mobile23_tester4/23mobileTester23), you will be asked to authorize the app (basic and likes scope). Once login/auth is complete, the login screen is replaced by the Stream screen. Stream screen is handled by StreamViewController, which is an UITableViewController. There's a logout button in top right, it clears the accessToken and takes user back to login screen.

I prefer not to use NIBs or storyboard, as from past experience storyboards have interfered with source control. As for NIBs, I prefer seeing everything happen in code, as opposed to the combination of code and UI. Dealing with UI elements in code gives me more granular control over positioning/sizing. I base widths of UI elements on the screen width, so the app will work on a phone of any size.

I am a fan of modular code. You can see that I put all networking code inside the Api/Api class. This class conforms to the singleton pattern to ensure that there's only one client in the app that talks to the Instagram API. The singleton stores accessToken, user object, a stream (list of posts), and list of likes (post_id->like_list).

If user has logged in before, he will not see the login screen. Opening the app will go straight to his media stream. the API's loadStreamFromApi is called every time the app launches. user/self/media/recent endpoint provides only the count of likes, but not the list of users that liked the post. In order to ascertain that any post was liked by the logged-in user, a separate API call is made to the media/##/likes endpoint for each post. This happens when a call to fetch entire stream is made. This is unfortunate because it results in this app's reaching the rate limit quickly. We get 500 requests per hour, which is easily reached by just a few runs of the app. When a like or unlike action is performed, an API request is made to media/##/likes endpoint to fetch the updated list of likes (that contains or does not contain your profile, depending on whether you liked or unliked the post). Then only the cell containing the post gets updated.

The rationale for using AFNetworking library is to utilize the UIImage cache provided by that library. Also, if image is fetched from the URL, AFNetworking library provides ability to show the placeholder image in its place until the image has been fetched.

NSNotificationCenter is used for communicating between ViewControllers and the API module.

NSUserDefaults is used to store the access token for persistence. When user exits the app and comes back, if he has logged in before, he sees the Stream right away. The stream is fetched upon entering the app, and if the API returns an invalid token error, user is redirected to the login screen automatically.

Suggested improvements include:

1. Use Core Data with sqlite3 db for storing the stream and likes, instead of storing everything in memory. This will reduce number of API requests, so that there's no need to re-fetch likes for every post.
2. Implement a handler to handle refreshing of the feed. Swiping the stream down (like in current instagram app) would result in a new call to the user/self/media/recent endpoint to refresh the feed in the app

