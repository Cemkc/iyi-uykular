using UnityEngine;

public class MouseDrag : MonoBehaviour
{
    private Orbit _orbit;
    private bool _isRotating = false;
    private Vector3 _mousePosRef;
    private Vector3 _mouseOffset;
    [SerializeField] private float _sensitivity;

    void Start()
    {
        _orbit = FindObjectOfType<Orbit>();
    }

    void Update()
    {
        Rotation();
    }

    private void Rotation()
    {
        if (Input.GetMouseButton(1))
        {
            if (!_isRotating)
            {
                _isRotating = true;
                _mousePosRef = Input.mousePosition;
            }

            _mouseOffset = (Input.mousePosition - _mousePosRef);
            _orbit._angle += -_mouseOffset.x * _sensitivity;
            _mousePosRef = Input.mousePosition;
        }
        else
        {
            if (_isRotating) { _isRotating = false; }
        }
    }
}
