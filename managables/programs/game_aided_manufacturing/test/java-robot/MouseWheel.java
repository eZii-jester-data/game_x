import java.awt.Robot;
// import java.awt.event.InputEvent;

public class MouseWheel {
    public static void main(String[] args) throws Exception {
        Robot robot = new Robot();    
        robot.mouseWheel(-100);
    }
}