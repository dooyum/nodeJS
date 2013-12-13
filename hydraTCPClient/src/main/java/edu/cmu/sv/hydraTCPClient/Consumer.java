package edu.cmu.sv.hydraTCPClient;

import java.util.concurrent.BlockingQueue;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.IOException;
import java.io.OutputStream;
import java.net.Socket;

public class Consumer implements Runnable{

    protected BlockingQueue<byte[]> queue = null;
    protected Socket socket = null;
    DataOutputStream dataOutputStream = null;
    //BufferedReader dataInputStream = null;
    private volatile boolean running;

    public Consumer(Socket socket, BlockingQueue<byte[]> queue) {
        this.queue = queue;
        this.socket = socket;
        running = true;

        OutputStream outputStream = null;
        try {
            outputStream = this.socket.getOutputStream();
        } catch (IOException e) {
            e.printStackTrace();
        }
        dataOutputStream = new DataOutputStream(outputStream);


        /*InputStream inputStream = null;
        try {
            inputStream = this.socket.getInputStream();
        } catch (IOException e) {
            e.printStackTrace();
        }
        dataInputStream = new BufferedReader(new InputStreamReader(inputStream));*/

    }

    public void run() {
        try {
            /*HydraInput hydraInput = new HydraInput(socket);
            Thread hydraInputThread = new Thread(hydraInput);
            hydraInputThread.start();*/

            short[] combinedBytes = new short[10];
            while(true){
                if(!queue.isEmpty()){
                    byte[] buffer = new byte[20];
                    buffer = queue.take();
                    //TOGO
                    combinedBytes = bytesToShort(buffer);
                    System.out.println("DATA READ FROM QUEUE: " + Integer.toHexString(combinedBytes[0] & 0xffff) + " " + Integer.toHexString(combinedBytes[1] & 0xffff) + " " + Integer.toHexString(combinedBytes[2] & 0xffff) + " " + Integer.toHexString(combinedBytes[3] & 0xffff) + " " + Integer.toHexString(combinedBytes[4] & 0xffff) + " " + Integer.toHexString(combinedBytes[5] & 0xffff) + " " + Integer.toHexString(combinedBytes[6] & 0xffff) + " " + Integer.toHexString(combinedBytes[7] & 0xffff) + " " + Integer.toHexString(combinedBytes[8] & 0xffff) + " " + Integer.toHexString(combinedBytes[9] & 0xffff));
                    try {
                        dataOutputStream.write(buffer);
                        dataOutputStream.flush();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }

        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    public void kill() {
        running = false;
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
}