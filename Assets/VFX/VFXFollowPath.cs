using UnityEngine;

public class VFXFollowPath : MonoBehaviour
{
    private float _followSpeed;
    private Transform _targetPoint;
    private ParticleSystem _particleSystem;

    void Start()
    {
        _particleSystem = GetComponent<ParticleSystem>();
    }

    void Update()
    {
        FollowPath();
    }

    private void FollowPath()
    {
        transform.position = Vector3.MoveTowards(transform.position, _targetPoint.position, _followSpeed);

        float distance = Vector3.Distance(transform.position, _targetPoint.position);

        if (distance == Mathf.Epsilon)
        {
            _particleSystem.Stop();
            Destroy(gameObject);
        }
    }
}
