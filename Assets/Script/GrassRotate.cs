using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrassRotate : MonoBehaviour
{
    // Start is called before the first frame update
    public float speed;
    public int index;
    public float force;
    Rigidbody rb;
    public float minimumSpeed;
    public GameObject disEffect;
    void Start()
    {
        rb = GetComponent<Rigidbody>();
        Destroy(gameObject, 15);
    }

    // Update is called once per frame
    void Update()
    {
        if (index == 1)
        {
            Vector3 vel=rb.velocity;
            vel = new Vector3(vel.x, vel.y, vel.z * speed);
            rb.velocity = vel;
        }
        if (index == 2)
        {
            Vector3 vel = rb.velocity;
            vel = new Vector3(vel.x, vel.y, vel.z * speed);
            rb.velocity = vel;
        }
        if (index == 3)
        {
            Vector3 vel = rb.velocity;
            vel = new Vector3(vel.x*speed, vel.y, vel.z );
            rb.velocity = vel;
        }
        if (index == 4)
        {
            Vector3 vel = rb.velocity;
            vel = new Vector3(vel.x * speed, vel.y, vel.z);
            rb.velocity = vel;
        }

        SpeedTest();
    }

    void SpeedTest()
    {
        Vector3 v = rb.velocity;
        float m01 = Mathf.Sqrt(Mathf.Pow(v.x, 2) + Mathf.Pow(v.y, 2) + Mathf.Pow(v.z, 2));
        if (m01 <minimumSpeed)
        {
            Instantiate(disEffect,transform.position,Quaternion.identity);
            Destroy(gameObject);
        }
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Player"))
        {
            collision.gameObject.GetComponent<GraspMilkBox>().isHit = true;
            collision.gameObject.GetComponent<GraspGun>().isHit = true;
            SoundsManager.PlayDamageAudio();
            Vector3 dir = collision.transform.position - transform.position;
            collision.gameObject.GetComponent<Rigidbody>().AddForce(dir * force, ForceMode.Impulse);
            collision.gameObject.GetComponentInParent<PlayerMovement>().PlayerDizziness(3f);
            Instantiate(disEffect, transform.position, Quaternion.identity);
            Destroy(gameObject);
        }
    }
}
