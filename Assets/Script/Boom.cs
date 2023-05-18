using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Boom : MonoBehaviour
{
    [Header("炮弹旋转速度")]
    public float degreesPerSecond;
    [Header("炮弹移动速度")]
    public float moveSpeed;
    [Header("炮弹移动控制")]
    public GameObject boomParent;
    [Header("炮弹爆炸特效")]
    public GameObject explosionEffect;
    [Header("炮弹力度")]
    public float explosionForce;
    public float explosionUpForce;
    [Header("炮弹方向跟随物体")]
    public GameObject cannon;
    // Start is called before the first frame update
    void Start()
    {
        Destroy(gameObject, 15);
    }

    // Update is called once per frame
    void Update()
    {
        BoomRotate();
        BoomMove();
    }

    void BoomRotate()
    {
        if (boomParent.transform.rotation == Quaternion.Euler(0, 0, 0))
        {
            transform.Rotate(new Vector3(0f, 0f, Time.deltaTime * degreesPerSecond), Space.World);
        }
        if (boomParent.transform.rotation == Quaternion.Euler(0, 180, 0))
        {
            transform.Rotate(new Vector3(0f, 0f, -Time.deltaTime * degreesPerSecond), Space.World);
        }
        if (boomParent.transform.rotation == Quaternion.Euler(0, 90, 0))
        {
            transform.Rotate(new Vector3(Time.deltaTime * degreesPerSecond, 0f, 0f), Space.World);
        }
        if (boomParent.transform.rotation == Quaternion.Euler(0, -90, 0))
        {
            transform.Rotate(new Vector3(-Time.deltaTime * degreesPerSecond, 0f, 0f), Space.World);
        }
    }
    void BoomMove()
    {
        boomParent.transform.Translate(Time.deltaTime * moveSpeed, 0, 0);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            Vector3 forceDirect = other.transform.position - transform.position;
            Vector3 forceDirectProcess = new Vector3(forceDirect.x*explosionForce, explosionUpForce, forceDirect.y*explosionForce);
            SoundsManager.PlayExplosionAudio();
            Instantiate(explosionEffect, transform.position, Quaternion.Euler(0,0,0));
            other.GetComponent<Rigidbody>().AddForce(forceDirectProcess);
            Destroy(gameObject);
        }
    }

}
