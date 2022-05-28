using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class Orbit : MonoBehaviour
{
    [SerializeField] private List<Transform> Cameras;
    public float _cameraPitch;
    [SerializeField] private float _maskAngleOffset;
    [SerializeField] private float _maskHeightOffset;
    [SerializeField] private Transform _mask;
    public float _cameraRadius;
    [SerializeField] private float _maskRadius;
    public float _angle;
    [HideInInspector] public Vector3 _cameraForward;
    [HideInInspector] public Vector3 _cameraRight;

    private float _rotationInput;
    [SerializeField] private float _rotateSpeed;
    
    void Update()
    {
        OrbitCamera();
        OrbitMask();
        CameraRotation();
    }

    private void OrbitCamera()
    {
        float rad = (_angle - 90) * Mathf.Deg2Rad;
        Vector3 direction = Vector3.zero;
        direction.x = Mathf.Cos(rad);
        direction.z = Mathf.Sin(rad);

        Vector3 finalPosition = transform.position + direction * _cameraRadius;
        Vector3 offset = new Vector3(0, _cameraPitch, 0);

        foreach (Transform camera in Cameras)
        {
            camera.position = finalPosition + offset;

            camera.LookAt(transform.position, Vector3.up);
        }     

        _cameraForward = direction;
        _cameraRight = CalculateCammeraRight();
    }

    private Vector3 CalculateCammeraRight()
    {
        float rad = (_angle) * Mathf.Deg2Rad;
        Vector3 direction = Vector3.zero;
        direction.x = Mathf.Cos(rad);
        direction.z = Mathf.Sin(rad);
        return direction;
    }

    private void OrbitMask()
    {
        float rad = (_angle + _maskAngleOffset - 90) * Mathf.Deg2Rad;
        Vector3 direction = Vector3.zero;
        direction.x = Mathf.Cos(rad);
        direction.z = Mathf.Sin(rad);

        Vector3 finalPosition = transform.position + direction * _maskRadius;
        Vector3 offset = new Vector3(0, _maskHeightOffset, 0);

        _mask.position = finalPosition + offset;
    }   

    private void CameraRotation()
    {
        _angle += (InputMaster.cameraAxisInput * _rotateSpeed * Time.deltaTime);
    }

}

