package edu.cmu.sv.hydraTCPClient;

import java.util.ArrayList;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.FileWriter;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.lang.Exception;
import java.net.ServerSocket;
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
        ArrayList<Socket> hydraSockets = new ArrayList<Socket>();
        ArrayList<Integer> callbackPorts = new ArrayList<Integer>();
        for (int index = 0 ; index < args.length ; index +=3) {
            String hydraAddress = args[index];
            Integer hydraPort = Integer.parseInt(args[index + 1]);
            hydraSockets.add(new Socket(hydraAddress, hydraPort));
            callbackPorts.add(Integer.parseInt(args[index+2]));
        }
        

        //create thread to get raw data
        Producer producer = new Producer(input, queue);
        Thread producerThread = new Thread(producer);
        producerThread.start();

        //create thread to push raw data to HYDRA
        Consumer consumer = new Consumer(hydraSockets, queue);
        Thread consumerThread = new Thread(consumer);
        consumerThread.start();

        for (int index = 0; index < callbackPorts.size(); index++) {
            //create thread to push transcriptions to callback ports
            Response response = new Response(hydraSockets.get(index), callbackPorts.get(index));
            Thread responseThread = new Thread(response);
            responseThread.start();
        }
    }
}