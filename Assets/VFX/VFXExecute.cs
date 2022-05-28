
using System.Collections.Generic;
using UnityEngine;

public class VFXExecute : MonoBehaviour
{
    [SerializeField] private List<GameObject> _particles = new List<GameObject>();
    [SerializeField] private Transform _parent;

    public void PlayParticles()
    {
        foreach (GameObject particle in _particles)
        {
            GameObject obj = Instantiate(particle, gameObject.transform.position, Quaternion.identity, _parent);
        }
    }
}
