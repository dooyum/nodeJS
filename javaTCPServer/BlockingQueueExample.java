import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.InputStreamReader;
import java.net.Socket;

public class HydraTCPClient {
    public static void main(String[] args) throws Exception {

        //Receive data from ffmpeg server
        DataInputStream input = new DataInputStream(System.in);
        BlockingQueue<byte[]> queue = new LinkedBlockingQueue<byte[]>();

        //setup HYDRA Connection
        String hydraAddress = args[0];
        Integer hydraPort = Integer.parseInt(args[1]);
        Socket hydraSocket = new Socket(hydraAddress, hydraPort);

        Producer producer = new Producer(input, queue);
        Consumer consumer = new Consumer(hydraSocket, queue);

        Thread producerThread = new Thread(producer);
        producerThread.start();
        Thread consumerThread = new Thread(consumer);
        consumerThread.start();

        BufferedReader inFromHydra = new BufferedReader(new InputStreamReader(hydraSocket.getInputStream()));
        
        String dataFromHydra;

        while(true){
            if((dataFromHydra = inFromHydra.readLine()) != null){
                System.out.println("TRANSCRIPT FROM HYDRA: " + dataFromHydra);
            }
        }
    }
}