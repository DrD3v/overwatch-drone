# Overwatch Drone

The goal of the Overwatch project was to develop a drone that can be activated on-demand, to find and track the caller. Using GPS and a live video stream, the drone follows and records the caller to provide additional security and evidence in case of an incident.
This project was handed over at the proof of concept stage.

# Proof of concept

The main task of an Overwatch drone is to track the person that initiated the command. This requires the drone to autonomously locate and follow that person while avoiding obstacles. 
Commercial drones provide a degree of collision avoidance and camera-based object tracking. This proof of concept stage focussed on locating the initiating device, capturing the person operating this device in a video stream (to allow camera-based tracking to take over) and returning to the drones original starting location.

**Limitations**

The Overwatch drone can only be initiated from a mobile device running the Overwatch app. The mobile device has to create a WiFi hotspot to which the drone connects to send and receive data from the smartphone. 
The drone has a limited operating distance of 50 meters.
The drone's video feed is only available on the initiating smartphone.
The drone does not have any autonomous collision detection. The drone tracks it's path from lift off which it will backtrack when it is returning home, to avoid potential obstacles in unintended flight paths.
The camera is fixed to the drone's frame, to capture the operator in frame, the drone has to adjust its distance from the target and altitude.


**Drone Setup**

To accommodate additional hardware, the drone was constructed from individual parts rather than purchased pre-built. 

![IMG_20201105_151350](https://github.com/DrD3v/overwatch-drone/assets/48776257/4e1a6595-51bc-4f96-a92c-f6ce31089c73)

Using standard and custom (3D printed) drone components, the drone accommodates a companion computer (Raspberry Pi 4), a camera with zoom lens, a WiFi module and a high accuracy GPS module, besides the drone components required for basic flight. 

![IMG_20201109_172510](https://github.com/DrD3v/overwatch-drone/assets/48776257/eefae7ec-1ee6-4120-a484-b783697a8887)


**Methods**

Using Dronekit and Mavlink components for basic flight and their command library as building blocks for autonomous flight, a Python interface was developed that runs on the Drone's on-board computer. This interface allows access to the flight controls from an external source, in this case the companion computer. 
The Raspberry Pi companion computer is connected to the WiFi, camera and GPS modules and runs a Python script that parses incoming data and sends flight commands to the Drone using the developed interface.

Once the companion computer is connected to a WiFi hotspot and receives a start command from a connected smartphone, the drone ascends to a safe operating height of 15 meters. Using GPS data received from the connected smartphone, the companion computer calculates a path towards the operator. To avoid unintended behaviour, the GPS data is analysed before plotting a course. Any GPS data that is more than 50 meters from the drone's current location is discarded to avoid leaving the WiFi hotspot range. Any GPS data that is more than 2 meters from previous GPS data has to be confirmed by additional data packages to avoid unintended drone behaviour. To capture the operator in the mounted camera's viewfield, the drone keeps 5 a meter distance while facing the camera towards the operator. 
Once the operator dismisses the drone via smartphone, it retraces its flightpath and lands at its home location.
The drone will also return to home when a low battery signal is received.

https://dronekit.io/
https://mavlink.io/en/
https://fast-dds.docs.eprosima.com/en/v1.7.0/

https://github.com/DrD3v/overwatch-drone/assets/48776257/871ed650-9fe9-4389-a130-46e5b1925e84


**Future work and conclusion**

To extend this work to a MVP stage, several limitations have to be removed.
Instead of connecting to the drone via WiFi, the drone has to be connected to a cellular network, allowing devices to connect via the internet and removing any distance restrictions.
Collision avoidance has to be implemented that detects obstacles JIT as well as using maps of known surroundings. The plotted path to the target will have to be adjusted accordingly and might have to introduce an additional degree of freedom by allowing the drone to adjust its altitude.
Camera based object tracking has to be implemented which takes over from GPS based tracking once the operator has been located.
Data captured by the drone, such as the video stream and GPS data, have to be stored externally to be available for review.

While this ambitious project was started with good intentions such as increased personal security, it is very unlikely to move past its current stage in the near future. Strict regulations on drones (especially with autonomous capabilities) make it practicall

