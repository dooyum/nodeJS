package edu.cmu.sv.hydraTCPClient;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.IOException;
import java.io.OutputStream;
import java.net.ServerSocket;
import java.net.Socket;

import org.json.*;

public class Response implements Runnable{

    Socket hydraSocket = null;
    Integer callbackPort = null;

    //BufferedReader dataInputStream = null;
    private volatile boolean running;

    public Response(Socket hydraSocket, Integer callbackPort) {
        this.hydraSocket = hydraSocket;
        this.callbackPort = callbackPort;
        running = true;
    }

    public void run() {
        //receive transcription from HYDRA and post to specified callback address
        BufferedReader inFromHydra = null;
        try{
            inFromHydra = new BufferedReader(new InputStreamReader(hydraSocket.getInputStream()));
        } catch (IOException e){
            e.printStackTrace();
        }
        String dataFromHydra = null;

        boolean callBackRequested = false;
        DataOutputStream outToCallback = null;

        if(callbackPort != 0){
            callBackRequested = true;

           //setup callback Connection
            try{
                ServerSocket webServerSocket = new ServerSocket(callbackPort);
                Socket webSocket = webServerSocket.accept();
                outToCallback = new DataOutputStream(webSocket.getOutputStream());
            } catch (IOException e){
                e.printStackTrace();
            }  
        }
        
        //Create transcript file        
        //PrintWriter transcript = new PrintWriter("transcript.txt", "UTF-8");
        //transcript.close();

        while(true){
            //read data from HYDRA
            try{
                dataFromHydra = inFromHydra.readLine();
            } catch (IOException e){
                dataFromHydra = null;
                e.printStackTrace();
            }

            if(dataFromHydra != null){
                //System.out.println("TRANSCRIPT FROM HYDRA: " + dataFromHydra);

                //alternatively write transcript to file
                // PrintWriter writer = new PrintWriter(new FileWriter("transcript.txt", true));
                // writer.println(dataFromHydra);
                // writer.close();

                if(callBackRequested){
                    //create json object of transcription of words and send if the data is appropriate
                    if(!dataFromHydra.startsWith("RESULT:")){
                        String[] transcriptParameters = dataFromHydra.split(",");

                        JSONObject json = new JSONObject();
                        try{
                            json.put("word", transcriptParameters[0]);
                            json.put("start", transcriptParameters[1]);
                            json.put("end", transcriptParameters[2]);
                        } catch (JSONException e){
                            e.printStackTrace();
                        }

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

    public void kill() {
        running = false;
    }
}