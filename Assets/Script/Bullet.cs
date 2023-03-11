using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bullet : MonoBehaviour
{
    public float speed = 8f;  //子弹速度
    public GameObject player;
    GameObject rope;
    GameObject ropCreated;

    void Start()
    {
        Destroy(gameObject, 7f);  //7s后销毁自身
    }

    void Update()
    {
        transform.Translate(0, 0, Time.deltaTime * speed); //子弹位移     
        if (rope)
        {
            Debug.Log("Find");
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player")
        {
            //CreatRope(other.gameObject);
            Debug.Log("Hit!!!");
        }
        
    }
    void CreatRope(GameObject other)
    {
        ropCreated = rope;
        ropCreated.SetActive(true);
        ropCreated.GetComponent<RopeToolkit.Rope>().spawnPoints[0] = player.transform.position;
        ropCreated.GetComponent<RopeToolkit.Rope>().spawnPoints[1] = other.transform.position;
        

    }
}