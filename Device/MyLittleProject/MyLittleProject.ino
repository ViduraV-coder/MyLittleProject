// Import required libraries
#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <ESPAsyncTCP.h>
#include <ESPAsyncWebServer.h>
#include <ArduinoJson.h>
#include <RBDdimmer.h>

// Set network credentials
const char* ssid = "Ye Olde Internet";
const char* password = "Y#O#I#69";

// Set relay pins
#define DIMMER_PWM_PIN 16
#define DIMMER_ZC_PIN 5
#define RELAY_CEILING_SPEAKERS_PIN 12
#define RELAY_TABLE_SPEAKERS_PIN 0
#define RELAY_LIGHT1_PIN 2
#define RELAY_LIGHT2_PIN 14
#define RELAY_SUB_PIN 13

// default values
bool FAN_STATE = false;
int FAN_SPEED = 50;
bool CEILING_SPEAKERS = false;
bool TABLE_SPEAKERS = false;
bool LIGHT1 = false;
bool LIGHT2 = false;
bool SUB = false;

// Create AsyncWebServer object on port 80
AsyncWebServer server(80);

// Initialize port for dimmer
dimmerLamp dimmer(DIMMER_PWM_PIN, DIMMER_ZC_PIN);

void setup() {
  // Serial port for debugging purposes
  Serial.begin(115200);
  Serial.println();

  // attempt to connect to Wifi network:
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi ..");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print('.');
    delay(1000);
  }
  WiFi.setAutoReconnect(true);
  WiFi.persistent(true);
  Serial.print("You're connected to the network");

  // Get IP
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());

  // Set pin modes
  pinMode(DIMMER_PWM_PIN, OUTPUT);
  pinMode(RELAY_CEILING_SPEAKERS_PIN, OUTPUT);
  pinMode(RELAY_TABLE_SPEAKERS_PIN, OUTPUT);
  pinMode(RELAY_LIGHT1_PIN, OUTPUT);
  pinMode(RELAY_LIGHT2_PIN, OUTPUT);
  pinMode(RELAY_SUB_PIN, OUTPUT);

  // Initialize the dimmer
  dimmer.begin(NORMAL_MODE, ON);

  // Handlers

  // Get all current values
  server.on("/get", HTTP_GET, [] (AsyncWebServerRequest * request) {
    AsyncResponseStream *response = request->beginResponseStream("application/json");
      DynamicJsonDocument json(1024);
      json["status"] = "ok";
      json["light1"] = LIGHT1;
      json["light2"] = LIGHT2;
      json["sub"] = SUB;
      json["ceiling"] = CEILING_SPEAKERS;
      json["table"] = TABLE_SPEAKERS;
      json["fan"] = FAN_STATE;
      json["speed"] = FAN_SPEED;
      serializeJson(json, *response);
      request->send(response);
  });

  // Send a POST request to <IP>/post with a form field message set to <message>
  server.on("/post", HTTP_POST, [](AsyncWebServerRequest * request) {
    String value;
    if (request->hasParam("light1", true)) {
      value = request->getParam("light1", true)->value();
      if(value == "true"){
        LIGHT1 = true;
      }else if(value == "false"){
        LIGHT1 = false;
      }
      request->send(200, "text/plain", "ok");

    } else if (request->hasParam("light2", true)) {
      value = request->getParam("light2", true)->value();
      if(value == "true"){
        LIGHT2 = true;
      }else if(value == "false"){
        LIGHT2 = false;
      }
      request->send(200, "text/plain", "ok");

    } else if (request->hasParam("sub", true)) {
      value = request->getParam("sub", true)->value();
      if(value == "true"){
        SUB = true;
      }else if(value == "false"){
        SUB = false;
      }
      request->send(200, "text/plain", "ok");

    } else if (request->hasParam("fan", true)) {
      value = request->getParam("fan", true)->value();
      if(value == "true"){
        FAN_STATE = true;
      }else if(value == "false"){
        FAN_STATE = false;
      }
      request->send(200, "text/plain", "ok");

    } else if (request->hasParam("speed", true)) {
      value = request->getParam("speed", true)->value();
      FAN_SPEED = value.toInt();
      request->send(200, "text/plain", "ok");

    } else if (request->hasParam("ceiling", true)) {
      value = request->getParam("ceiling", true)->value();
      if(value == "true"){
        CEILING_SPEAKERS = true;
      }else if(value == "false"){
        CEILING_SPEAKERS = false;
      }
      request->send(200, "text/plain", "ok");

    } else if (request->hasParam("table", true)) {
      value = request->getParam("table", true)->value();
      if(value == "true"){
        TABLE_SPEAKERS = true;
      }else if(value == "false"){
        TABLE_SPEAKERS = false;
      }
      request->send(200, "text/plain", "ok");
      
    } else if (request->hasParam("off", true)) {
      LIGHT1 = false;
      LIGHT2 = false;
      SUB = false;
      FAN_STATE = false;
      FAN_SPEED = 50;
      CEILING_SPEAKERS = false;
      TABLE_SPEAKERS = false;
      request->send(200, "text/plain", "ok");
      
    } else{
      request->send(400, "text/plain", "Bad request");
    }
  });
 
  // Start server
  server.begin();
}

void loop() {
  if (FAN_STATE == false) {
     dimmer.setState(OFF); 
  } else if (FAN_STATE == true) {
     dimmer.setState(ON); 
  }
  
  dimmer.setPower(FAN_SPEED);

  if (LIGHT1 == false) {
    digitalWrite(RELAY_LIGHT1_PIN, HIGH);
  } else if (LIGHT1 == true) {
    digitalWrite(RELAY_LIGHT1_PIN, LOW);
  }

  if (LIGHT2 == false) {
    digitalWrite(RELAY_LIGHT2_PIN, HIGH);
  } else if (LIGHT2 == true) {
    digitalWrite(RELAY_LIGHT2_PIN, LOW);
  }

  if (SUB == false) {
    digitalWrite(RELAY_SUB_PIN, HIGH);
  } else if (SUB == true) {
    digitalWrite(RELAY_SUB_PIN, LOW);
  }

  if (CEILING_SPEAKERS == false) {
    digitalWrite(RELAY_CEILING_SPEAKERS_PIN, HIGH);
  } else if (CEILING_SPEAKERS == true) {
    digitalWrite(RELAY_CEILING_SPEAKERS_PIN, LOW);
  }

  if (TABLE_SPEAKERS == false) {
    digitalWrite(RELAY_TABLE_SPEAKERS_PIN, HIGH);
  } else if (TABLE_SPEAKERS == true) {
    digitalWrite(RELAY_TABLE_SPEAKERS_PIN, LOW);
  }
}
