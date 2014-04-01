import java.io.*;
import java.net.*;

class ReceivingTCPClient2
{
  public static void main(String argv[]) throws Exception
  {
    String transcript;
    Socket clientSocket = new Socket("localhost", 7000);
    BufferedReader inFromServer = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));

    while(true){
      transcript = inFromServer.readLine();
      if(transcript != null){
        System.out.println(transcript);
      }
    }
  }
}