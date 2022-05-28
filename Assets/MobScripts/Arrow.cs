using System.Collections;
using UnityEngine;
public class Arrow : MonoBehaviour
{
    [SerializeField] float DestroyTime;
    [SerializeField] float speed;
    Vector3 Firstpos;
    GameObject parentObject;
    float time;
    void OnEnable()
    {
        time = 0;
        parentObject = transform.parent.gameObject;
        transform.SetParent(null);
    }   
    void Update()
    {
        transform.Translate(Vector3.forward * speed * Time.deltaTime);
        time += Time.deltaTime;
        if(time > DestroyTime)
        {
            StartCoroutine(Delay());
        }
    }
    void OnTriggerEnter(Collider col)
    {
        if(col.gameObject.tag == "Player")
        {
            StartCoroutine(Delay());
            //---
            col.gameObject.transform.GetComponent<PlayerStats>().TakeDamage(25);
        }
    }
    IEnumerator Delay()
    {
        yield return new WaitForSecondsRealtime(0.02f);
        time = 0;
        if(parentObject == null) Destroy(gameObject);
        transform.SetParent(parentObject.transform);
        transform.localPosition = new Vector3(0,0,0);
        transform.localRotation = Quaternion.Euler(0,0,0);
        gameObject.SetActive(false);
    }
}
