using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterClamp : MonoBehaviour
{
    [SerializeField] private Transform _center;
    [SerializeField] private float _radius;
    [SerializeField] private Transform _target;

    [SerializeField] private float _moveStartRadius;
    [SerializeField] private float _moveSpeed;
    [SerializeField] private Transform _moveTarget;
    [SerializeField] private float _heightOffset;

    void Update()
    {
        float distance = Vector3.Distance(_target.position, _center.position);

        if (distance > _radius)
        {
            Vector3 fromOriginToObject = _target.position - _center.position;
            fromOriginToObject *= _radius / distance;
            _target.position = _center.position + fromOriginToObject;
        }


        float multiplier = (Mathf.Abs(distance / _radius));
        if (distance >= _moveStartRadius) 
        {
            MoveCamera(_moveSpeed * multiplier);
        }      
    }

    private void MoveCamera(float speed)
    {
        Vector3 targetPos = new Vector3(_target.position.x, _target.position.y + _heightOffset, _target.position.z);
        _moveTarget.position = Vector3.MoveTowards(_moveTarget.position, targetPos, speed * Time.deltaTime);
    }

    private void OnDrawGizmos()
    {
        Gizmos.DrawWireSphere(_center.position, _radius);

        Gizmos.color = Color.green;
        Gizmos.DrawWireSphere(_center.position, _moveStartRadius);
    }
}
