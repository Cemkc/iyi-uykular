using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class Timer : MonoBehaviour
{
    public UnityEvent Event;

    public void StartTimer(float delay)
    {
        Invoke("Delay", delay * Time.deltaTime);
    }

    private void Delay()
    {
        Event!.Invoke();
        Destroy(gameObject);
    }
}
