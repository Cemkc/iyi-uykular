using UnityEngine;
using UnityEngine.Events;

[RequireComponent(typeof(Rigidbody))]
public class VFXCollision : MonoBehaviour
{
    [SerializeField] private int[] _layers;
    public UnityEvent OnCollision;

    private void OnTriggerEnter(Collider other)
    {
        if(other.tag == "Player")
        {
            other.GetComponent<PlayerStats>().TakeDamage(30);
        }
        foreach (int layer in _layers)
        {
            if (layer == other.gameObject.layer)
            {
                OnCollision!.Invoke();
                Destroy(gameObject);
                break;
            }
        }
    }
}
