using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotation : MonoBehaviour
{
    [Range(-360, 360)] [SerializeField] private float _rotation;

    void Update()
    {
        transform.Rotate(Vector3.up, _rotation * Time.deltaTime);
    }
}
