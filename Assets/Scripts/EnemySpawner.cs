using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class EnemySpawner : MonoBehaviour
{
    [SerializeField] private GameObject _enemy;
    [SerializeField] private List<GameObject> _spawnedEnemies;
    public UnityEvent Event;
    private bool _isSpawned = false;

    public void SpawnEnemies()
    {
        foreach (Transform target in transform.GetComponentsInChildren<Transform>())
        {
            GameObject obj = Instantiate(_enemy, target.position, Quaternion.identity);
            _spawnedEnemies.Add(obj);
        }
        _isSpawned = true;
    }

    private void Update()
    {
        if (_spawnedEnemies.Count == 0 && _isSpawned)
        {
            Event!.Invoke();
            Destroy(gameObject);
        }
    }
}
