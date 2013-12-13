import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.IOException;
import java.net.Socket;

public class HydraInput implements Runnable{

    protected Socket socket = null;
    BufferedReader dataInputStream = null;
    private volatile boolean running;

    public HydraInput(Socket socket) {
        this.socket = socket;
        running = true;

        InputStream inputStream = null;
        try {
            inputStream = this.socket.getInputStream();
        } catch (IOException e) {
            e.printStackTrace();
        }
        dataInputStream = new BufferedReader(new InputStreamReader(inputStream));
    }

    public void run() {
        boolean readyToRead = false;
        try {
            String dataFromHydra;
            while(true){
                if((dataFromHydra = dataInputStream.readLine()) != null){
                    System.out.println("FROM HYDRA: " + dataFromHydra);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void kill() {
        running = false;
    }
}