import java.io.*;
import java.net.*;
import javax.sound.sampled.*;

class TCPClient
{
 public static void main(String argv[]) throws Exception
 {
  Socket clientSocket = new Socket("localhost", 6789);
  DataOutputStream outToServer = new DataOutputStream(clientSocket.getOutputStream());
  DataInputStream inFromServer = new DataInputStream(clientSocket.getInputStream());
  File file = new File("./output.raw");  
  //Uncomment the following line for file with known audio format
  //AudioInputStream ais = AudioSystem.getAudioInputStream(file);  
  FileInputStream ais = new FileInputStream(file);
  byte[] data = new byte[ais.available()];
  byte[] dataFromServer = new byte[ais.available()];  
  ais.read(data);
  outToServer.write(data);
  inFromServer.read(dataFromServer);
  /*for (int i = 0; i < dataFromServer.length ;i++ ) {
      System.out.println("Shit happens");

      System.out.println(dataFromServer[i]);
  }
  System.out.println("Shit happens");*/
  clientSocket.close();
 }
}