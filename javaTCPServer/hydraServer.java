import java.io.*;
import java.io.ByteArrayInputStream;
import java.net.*;
import java.nio.*;

class hydraServer
{
   public static void main(String argv[]) throws Exception
   {
      String clientSentence;
      String capitalizedSentence;
      ServerSocket welcomeSocket = new ServerSocket(10530);

      while(true)
      {
         Socket connectionSocket = welcomeSocket.accept();
         DataInputStream inFromClient = new DataInputStream(connectionSocket.getInputStream());
         DataOutputStream outToClient = new DataOutputStream(connectionSocket.getOutputStream());
         byte[] dataFromClient = new byte[1028];
         int dataLeft = 1;
         while(dataLeft != 0){
            System.out.println("Reading: " + inFromClient.read(dataFromClient));
            dataLeft = inFromClient.available();
            System.out.println("DATA: " + dataFromClient[1]);
            System.out.println("Data Left: " + inFromClient.available());
         }
        outToClient.writeBytes("This message is a translation from hydra");
      }
   }
}