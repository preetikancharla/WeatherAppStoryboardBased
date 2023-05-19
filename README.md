# WeatherAppStoryboardBased

# Create a browser or native-app-based application to serve as a basic weather app.
I have created a Native app using UIKit/Swift as directions mentioned UIKit as mandatory.

# Search Screen

# Allow customers to enter a US city 
City can be added in the text field. When user is done entering the city, whether for that city will be displayed.

# Call the openweathermap.org API and display the information you think a user would be interested in seeing. Be sure to has the app download and display a weather icon. 
City name, weather icon and weather description will be displayed.

# Have image cache if needed 
The weather images are cached at session level.

# Auto-load the last city searched upon app launch 
implemented using user defaults. 

# Ask the User for location access, If the User gives permission to access the location, then retrieve weather data by default 
Implemented. The screen refreshes the first time permission is granted through delegate framework between view controller and location handler. It could also be implemented as subscribers model.


In addition to above, I have implemented following to design patterns to demonstrate knowledge of design patterns. 
- singleton pattern for location handler
- delegate framework between view controller and location handler 

I have added UI support for error handling when city name is invalid. Other errors are also returned but I have not had time to build UI to show those errors. 

UI control sizes are deliberately kept smaller to handle both device orientations. Much can be done to take full benefit of UI Screen but have not spent time on UI as this was clearly mentioned as low priority.
