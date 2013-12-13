package edu.cmu.sv.hydraTCPClient;

import java.util.concurrent.BlockingQueue;
import java.io.DataInputStream;
import java.nio.*;
import java.io.IOException;

public class Producer implements Runnable{
    protected BlockingQueue<byte[]> queue = null;
    protected DataInputStream input = null;

    public Producer(DataInputStream input, BlockingQueue<byte[]> queue) {
        this.input = input;
        this.queue = queue;
    }

    public void run() {
        try {
            //buffer to hold incoming shorts
            byte[] dataFromInput = new byte[16];
            boolean incomingDataAvailable = true;     
            int dataLeft = 0;

            while(incomingDataAvailable){
                Integer dataRead;
                try {
                    dataRead = input.read(dataFromInput);
                } catch (IOException e) {
                    dataRead = 0;
                    e.printStackTrace();
                }

                //add buffer to the queue
                queue.put(kaldiFormat(dataFromInput));

                //check if there is unread input
                try {
                    dataLeft = input.available();
                } catch (IOException e) {
                    dataLeft = 0;
                    e.printStackTrace();
                }
                if(dataLeft == 0){
                  incomingDataAvailable = false;
                }

                //TOGO
                short[] combinedBytes = new short[8];
                combinedBytes = bytesToShort(dataFromInput);
                System.out.println("DATA WRITTEN TO QUEUE: " + Integer.toHexString(combinedBytes[0] & 0xffff) + " " + Integer.toHexString(combinedBytes[1] & 0xffff) + " " + Integer.toHexString(combinedBytes[2] & 0xffff) + " " + Integer.toHexString(combinedBytes[3] & 0xffff) + " " + Integer.toHexString(combinedBytes[4] & 0xffff) + " " + Integer.toHexString(combinedBytes[5] & 0xffff) + " " + Integer.toHexString(combinedBytes[6] & 0xffff) + " " + Integer.toHexString(combinedBytes[7] & 0xffff));
                System.out.println("INCOMING DATA LEFT TO READ: " + dataLeft + " BYTES");
             }

        } catch (InterruptedException e) {
            e.printStackTrace();
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