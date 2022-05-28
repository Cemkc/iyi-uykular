using UnityEngine;

public class CharacterHealth : MonoBehaviour
{
    [SerializeField] float Health;
    [SerializeField] float Attack1;
    [SerializeField] float Attack2;
    [SerializeField] float Attack3;

    void OnTriggerEnter(Collider col)
    {
        if(col.gameObject.tag == "Attack1")
        {
            Health -= Attack1;
        }
        else if(col.gameObject.tag == "Attack1")
        {
            Health -= Attack2;
        }
        else if(col.gameObject.tag == "Attack3")
        {
            Health -= Attack3;
        }
    }
}
