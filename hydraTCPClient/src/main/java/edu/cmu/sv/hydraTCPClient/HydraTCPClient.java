package edu.cmu.sv.hydraTCPClient;

import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.FileWriter;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.lang.Exception;
import java.net.Socket;

import org.apache.http.*;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;

import org.json.*;

public class HydraTCPClient {
    public static void main(String[] args) throws Exception {

        //Receive data from ffmpeg server
        DataInputStream input = new DataInputStream(System.in);
        BlockingQueue<byte[]> queue = new LinkedBlockingQueue<byte[]>();
        BlockingQueue<String> transcriptQueue = new LinkedBlockingQueue<String>();

        //setup HYDRA Connection
        String hydraAddress = args[0];
        Integer hydraPort = Integer.parseInt(args[1]);
        Socket hydraSocket = new Socket(hydraAddress, hydraPort);

        //create thread to get raw data
        Producer producer = new Producer(input, queue);
        Thread producerThread = new Thread(producer);
        producerThread.start();

        //create thread to push raw data to HYDRA
        Consumer consumer = new Consumer(hydraSocket, queue);
        Thread consumerThread = new Thread(consumer);
        consumerThread.start();

        OutgoingTCPServer server = new OutgoingTCPServer(transcriptQueue);
        Thread serverThread = new Thread(server);
        serverThread.start();

        //receive transcription from HYDRA and post to specified callback address
        BufferedReader inFromHydra = new BufferedReader(new InputStreamReader(hydraSocket.getInputStream()));
        String dataFromHydra;

        boolean callBackRequested = false;
        Integer callbackPort = 0;
        //CloseableHttpClient httpClient = null;
        //if callback argument is set
        if(args.length > 2){
            callBackRequested = true;
            // callback address format is "http://10.0.22.147:3001/today"
            callbackPort = Integer.parseInt(args[2]);

           //setup callback Connection
            ServerSocket webServerSocket = new ServerSocket(callbackPort);
            Socket webSocket = webServerSocket.accept();
            DataOutputStream outToCallback = new DataOutputStream(webSocket.getOutputStream());
        }
        
        //Create transcript file        
        PrintWriter transcript = new PrintWriter("transcript.txt", "UTF-8");
        transcript.close();

        while(true){
            //read data from HYDRA
            if((dataFromHydra = inFromHydra.readLine()) != null){
                System.out.println("TRANSCRIPT FROM HYDRA: " + dataFromHydra);

                //alternatively write transcript to file
                PrintWriter writer = new PrintWriter(new FileWriter("transcript.txt", true));
                writer.println(dataFromHydra);
                writer.close();

                if(callBackRequested){
                    //create json object of transcription of words and send if the data is appropriate
                    if(!dataFromHydra.startsWith("RESULT:")){
                        String[] transcriptParameters = dataFromHydra.split(",");

                        JSONObject json = new JSONObject();
                        json.put("word", transcriptParameters[0]);
                        json.put("start", transcriptParameters[1]);
                        json.put("end", transcriptParameters[2]);

                        try {
                            outToCallback.writeBytes(json.toString() + '\n');
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }
            }
        }
    }
}