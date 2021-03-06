import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.InputStreamReader;
import java.io.Exception;
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

        //create thread to get raw data
        Producer producer = new Producer(input, queue);
        Thread producerThread = new Thread(producer);
        producerThread.start();

        //create thread to push raw data to HYDRA
        Consumer consumer = new Consumer(hydraSocket, queue);
        Thread consumerThread = new Thread(consumer);
        consumerThread.start();

        //receive transcription from HYDRA and post to specified callback address
        BufferedReader inFromHydra = new BufferedReader(new InputStreamReader(hydraSocket.getInputStream()));
        String dataFromHydra;

        boolean callBackRequested = false;
        //if callback argument is set
        if(args.length > 2){
            callBackRequested = true;
            String callbackAddress = args[2];

            //create HTTP Client for callback
            CloseableHttpClient httpClient = HttpClientBuilder.create().build();
            //create json object of transcription
            JSONObject json = new JSONObject();
            json.put("transcription", "dataFromHydra");
            try {
                HttpPost request = new HttpPost("http://10.0.22.147:3001/today");
                StringEntity params = new StringEntity(json.toString());
                request.addHeader("content-type", "application/x-www-form-urlencoded");
                request.setEntity(params);
                //send callback
                HttpResponse response = httpClient.execute(request);
                int code = response.getStatusLine().getStatusCode();
                System.out.println("STATUS CODE: " + code);            
                // handle response here...
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                //TODO(dooyum) close client only after we have received all messages from HYDRA
                httpClient.close();
            }
        }

        while(true){
            //read data from HYDRA
            if((dataFromHydra = inFromHydra.readLine()) != null){
                System.out.println("TRANSCRIPT FROM HYDRA: " + dataFromHydra);
            }
        }
    }
}