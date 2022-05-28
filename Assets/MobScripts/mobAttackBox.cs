using UnityEngine;

public class mobAttackBox : MonoBehaviour
{
    
    private void OnTriggerEnter(Collider other)
    {
        if(other.tag == "Player")
        {
            if(gameObject.transform.parent.gameObject.name == "Golem")
            {
                other.gameObject.transform.GetComponent<PlayerStats>().TakeDamage(30f);
                return;
            }
            other.gameObject.transform.GetComponent<PlayerStats>().TakeDamage(GetComponentInParent<MobFeatures>().mobDamage); 
        }
    }
}
