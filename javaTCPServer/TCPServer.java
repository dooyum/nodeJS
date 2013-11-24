import java.io.*;
import java.io.ByteArrayInputStream;
import java.net.*;
import java.nio.*;

class TCPServer
{
   public static void main(String argv[]) throws Exception
   {
      String clientSentence;
      String capitalizedSentence;
      ServerSocket welcomeSocket = new ServerSocket(6789);

      //HYDRA Connection
      Socket hydraSocket = new Socket("10.0.20.160", 12345);
      //Socket hydraSocket = new Socket("localhost", 10530);
      //run this to send raw audio from ffmpeg to conversion server ... ffmpeg -i input.wav -f s16le -acodec pcm_s16le tcp://localhost:6789
      // or ffmpeg -i http://amber.streamguys.com:5530 -f s16le -acodec pcm_s16le tcp://localhost:6789

      while(true)
      {
         Socket connectionSocket = welcomeSocket.accept();
         DataInputStream inFromClient = new DataInputStream(connectionSocket.getInputStream());
         DataOutputStream outToHydra = new DataOutputStream(hydraSocket.getOutputStream());
         BufferedReader inFromHydra = new BufferedReader(new InputStreamReader(hydraSocket.getInputStream()));
         byte[] dataFromClient = new byte[16];
         //Set dataLeft equals to zero so that it goes into the loop
         int dataLeft = 1;

         while(dataLeft != 0){
            System.out.println("Reading: " + inFromClient.read(dataFromClient));
            dataLeft = inFromClient.available();
            short[] combinedBytes = new short[8];
            combinedBytes = bytesToShort(dataFromClient);
            System.out.println("DATA: " + Integer.toHexString(combinedBytes[0] & 0xffff) + " " + Integer.toHexString(combinedBytes[1] & 0xffff) + " " + Integer.toHexString(combinedBytes[2] & 0xffff) + " " + Integer.toHexString(combinedBytes[3] & 0xffff) + " " + Integer.toHexString(combinedBytes[4] & 0xffff) + " " + Integer.toHexString(combinedBytes[5] & 0xffff) + " " + Integer.toHexString(combinedBytes[6] & 0xffff) + " " + Integer.toHexString(combinedBytes[7] & 0xffff));
            System.out.println("Data Left: " + inFromClient.available());
            //write to HYDRA server
            outToHydra.write(kaldiFormat(dataFromClient));
         }
         String dataFromHydra;
         //TODO(dooyum) indicate when stream ends in order to close connection
         while((dataFromHydra = inFromHydra.readLine()) != null){
          System.out.println("FROM HYDRA: " + dataFromHydra);
         }
         System.out.println("---------------END OF TRANSCRIPTION----------------");
         //hydraSocket.close();
      }
   }

   public static short[] bytesToShort(byte[] b){
    if(b.length % 2 != 0) {
      return null;
    }

    short[] shorts = new short[b.length/2];
    for(int i = 0; i < shorts.length; i++) {
      shorts[i] = (short) (((b[i*2] << 8) & 0XFF00) | (b[i*2 + 1] & 0XFF));
    }

    return shorts;
   }

   public static byte[] kaldiFormat(byte[] wav) {
    /*
     * make the packet header
     */
    int header_size = 4; //file size only so 4 bytes (file size is int)
    
    //make a packet of the right size
    byte[] packet = new byte[wav.length + header_size];
    
    //get the data length bytes (little endian because Kaldi is weird like that)
    byte[] d_len_bytes;
    d_len_bytes = new byte[4];
    ByteBuffer.wrap(d_len_bytes).order(ByteOrder.LITTLE_ENDIAN).asIntBuffer().put(wav.length);
    
    /*
     * put the header into the packet.
     * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     * MAKE SURE TO CHANGE THIS IF YOU EVER CHANGE THE HEADER!!!!!!!
     * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     */
    for(int i = 0; i < d_len_bytes.length; i++) {
      packet[i] = d_len_bytes[i];
    }
    
    //put the data in the packet
    for(int i = header_size; i < packet.length; i++) {
      packet[i] = wav[i-header_size];
    }
    System.out.print(packet[0]);
    System.out.print(" " + packet[1]);      
    System.out.print(" " + packet[2]);      
    System.out.print(" " + packet[3]);      
    System.out.println("-----");      
 
    //send the packet
    return packet;
   }

}