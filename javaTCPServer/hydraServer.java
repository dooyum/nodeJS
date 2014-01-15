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
         byte[] dataFromClient = new byte[20];
         int index = 0;
         while(inFromClient.read(dataFromClient) > -1){
            System.out.println("DATA: " + dataFromClient[0]);
            if((index % 100) == 0) {
               outToClient.writeBytes("This message is a translation from hydra \r\n");
            }
            index ++;
         }
         System.out.println("Done Reading!!!");

      }
   }
}