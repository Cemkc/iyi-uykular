using UnityEngine;

public class DragonAttackBox : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        if(other.tag == "Player")
        {
            other.gameObject.transform.GetComponent<PlayerStats>().TakeDamage(GetComponentInParent<Dragon>().closeAttackDamage);
        }
    }
}
