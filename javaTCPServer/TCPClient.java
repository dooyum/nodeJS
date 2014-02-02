import java.io.*;
import java.net.*;

class TCPClient{
  public static void main(String argv[]) throws Exception{
    String modifiedSentence;
    DataInputStream inFromUser = new DataInputStream(System.in);
    
    boolean incomingDataAvailable = true;     
    int dataLeft = 0;

    Socket clientSocket = new Socket("localhost", 5000);

    DataOutputStream outToServer = new DataOutputStream(clientSocket.getOutputStream());
    BufferedReader inFromServer = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));

    while(incomingDataAvailable){
      byte[] dataRead = new byte[8];
      try {
          inFromUser.read(dataRead);
          System.out.println(dataRead);

      } catch (IOException e) {
          e.printStackTrace();
      }

      outToServer.write(dataRead);
      outToServer.flush();

      //check if there is unread input
      try {
          dataLeft = inFromUser.available();
      } catch (IOException e) {
          dataLeft = 0;
          e.printStackTrace();
      }
      if(dataLeft == 0){
        incomingDataAvailable = false;
        System.out.println("DATA IS DONE!!!");
      }
    }
    clientSocket.close();
  }
}