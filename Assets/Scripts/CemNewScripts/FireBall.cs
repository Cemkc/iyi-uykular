using UnityEngine;
using System.Collections;

public class FireBall : MonoBehaviour
{
    [SerializeField] float FireBallSpeed;
    [SerializeField] float FireBallDamage;
    public GameObject Target;
    Vector3 targetPosition;
    // Start is called before the first frame update
    void Start()
    {
        targetPosition = GameObject.FindWithTag("Player").transform.position;
    }

    // Update is called once per frame
    void Update()
    {
        //transform.Translate(Vector3.forward * Time.deltaTime * FireBallSpeed);
        transform.position = Vector3.MoveTowards(transform.position, targetPosition, FireBallSpeed * Time.deltaTime);
    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.tag == "Player")
        {
            other.GetComponent<PlayerStats>().TakeDamage(FireBallDamage);
        }
        Destroy(this);
    }

    IEnumerator DestroyTime()
    {
        yield return new WaitForSeconds(10);
        Destroy(this);
    }
}
