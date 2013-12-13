import java.io.*;
import java.net.*;
import java.nio.*;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

//TODO(dooyum) put read from source, write to hydra, read from hydra all on different threads
class hydra_TCPClient
{
   public static void main(String args[]) throws Exception
   {
      String hydraAddress = args[0];
      Integer hydraPort = Integer.parseInt(args[1]);

      //HYDRA Connection
      Socket hydraSocket = new Socket(hydraAddress, hydraPort);
      //run this to send raw audio from ffmpeg to conversion server ... ffmpeg -i input.wav -f s16le -acodec pcm_s16le - | java hydra_TCPClient <hydra server IP> <hydra server port>

     DataInputStream inFromClient = new DataInputStream(System.in);

     DataOutputStream outToHydra = new DataOutputStream(hydraSocket.getOutputStream());
     BufferedReader inFromHydra = new BufferedReader(new InputStreamReader(hydraSocket.getInputStream()));

     List<byte[]> outputQueue = Collections.synchronizedList(new LinkedList<byte[]>());
     byte[] dataFromClient = new byte[16];
     boolean incomingDataAvailable = true;
     boolean transcriptAvailable = false;
     int dataLeft;

     //input loop
     while(incomingDataAvailable){
        System.out.println("Reading: " + inFromClient.read(dataFromClient));
        //add byte array to the queue
        outputQueue.add(kaldiFormat(dataFromClient));
        dataLeft = inFromClient.available();
        if(dataLeft == 0){
          incomingDataAvailable = false;
        }
        short[] combinedBytes = new short[8];
        combinedBytes = bytesToShort(dataFromClient);
        System.out.println("DATA: " + Integer.toHexString(combinedBytes[0] & 0xffff) + " " + Integer.toHexString(combinedBytes[1] & 0xffff) + " " + Integer.toHexString(combinedBytes[2] & 0xffff) + " " + Integer.toHexString(combinedBytes[3] & 0xffff) + " " + Integer.toHexString(combinedBytes[4] & 0xffff) + " " + Integer.toHexString(combinedBytes[5] & 0xffff) + " " + Integer.toHexString(combinedBytes[6] & 0xffff) + " " + Integer.toHexString(combinedBytes[7] & 0xffff));
        System.out.println("Data Left: " + dataLeft);
     }

     //write to hydra
     while(!outputQueue.isEmpty() || incomingDataAvailable){
        //if queue is empty but data is still being read, skip sending output to hydra server
      if(!outputQueue.isEmpty()){
        outToHydra.write(outputQueue.remove(0));
        outToHydra.flush();
      }
     }

     String dataFromHydra;

     //input from hydra
     while((dataFromHydra = inFromHydra.readLine()) != null){
      System.out.println("FROM HYDRA: " + dataFromHydra);
      transcriptAvailable = true;
     }
     transcriptAvailable = false;


     System.out.println("---------------END OF TRANSCRIPTION----------------");

     //TODO(dooyum) indicate when stream to and from hydra ends in order to close connection
     /*if(outputQueue.isEmpty() && !incomingDataAvailable && !transcriptAvailable){
      hydraSocket.close();      
     }*/
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