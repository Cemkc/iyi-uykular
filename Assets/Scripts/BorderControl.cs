using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BorderControl : MonoBehaviour
{
    [SerializeField] private List<BoxCollider> boxColliders;

    private void Start()
    {
        foreach (BoxCollider collider  in GetComponentsInChildren<BoxCollider>())
        {
            boxColliders.Add(collider);
            collider.enabled = false;
        }
    }

    public void SpawnBorder()
    {
        foreach (BoxCollider collider in boxColliders)
        {
            collider.enabled = true;
        }
    }

    public void RemoveBorder()
    {
        foreach (BoxCollider collider in boxColliders)
        {
            collider.enabled = false;
        }
    }
}
