import java.io.*;
import java.net.*;

class TCPServer{

   public static void main(String argv[]) throws Exception{
      byte[] webClientData = new byte[8];
      ServerSocket webSocket = new ServerSocket(5000);

      while(true){
         Socket webClientSocket = webSocket.accept();

         //create incoming and outgoing paths to web client
         DataInputStream inFromWebClient = new DataInputStream(webClientSocket.getInputStream());
         DataOutputStream outToWebClient = new DataOutputStream(webClientSocket.getOutputStream());

         while(true){
            if(inFromWebClient.available() > 0){
               try {
                  inFromWebClient.read(webClientData);
                  //System.out.println(Integer.toHexString(webClientData[0] & 0xffff) + " " + Integer.toHexString(webClientData[1] & 0xffff) + " " + Integer.toHexString(webClientData[2] & 0xffff) + " " + Integer.toHexString(webClientData[3] & 0xffff) + " " + Integer.toHexString(webClientData[4] & 0xffff) + " " + Integer.toHexString(webClientData[5] & 0xffff) + " " + Integer.toHexString(webClientData[6] & 0xffff) + " " + Integer.toHexString(webClientData[7] & 0xffff));
                  System.out.write(webClientData);
               } catch (IOException e) {

               }
            }
         }
      }
   }
}