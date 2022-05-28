using UnityEngine;
using UnityEngine.Events;

public class BoxEventTrigger : MonoBehaviour
{
    public UnityEvent OnTrigger;

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player")
        {
            OnTrigger!.Invoke();
            Destroy(gameObject);
        }
    }
}
