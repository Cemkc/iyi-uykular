#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;

public class ScreenshotGrabber
{
    [MenuItem("Screenshot/Grab")]
    public static void Grab()
    {
        Debug.Log("Shot");
        string id = "";
        int i = 0;
        while(i < 10)
        {
            int a = Random.Range(0,9);
            id += a.ToString();
            i++;
        }
        Debug.Log(id);
        ScreenCapture.CaptureScreenshot("Assets/ScreenShots/Screenshot" + id +  ".png", 1);
    }
}
#endif